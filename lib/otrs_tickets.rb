module OtrsTickets
  #
  #  Rails Views
  #
  module Helper
    def get_ticket_view_url( remote_id='0' )
      uri = URI.parse(@conference.ticket_server.url)
      uri.path += 'index.pl'
      uri.query = "Action=AgentTicketZoom;TicketID=#{remote_id}"
      uri.to_s
    end
  end

  #
  # Otrs Server
  #
  class OtrsAdapter
    require 'uri'
    require 'net/http'

    def initialize(c, l)
      @conference = c
      @logger = l
      @test_only = false
    end
    attr_accessor :test_only

    def get_ticket_json_uri
      uri = URI(@conference.ticket_server.url)
      uri.path += 'json.pl'
      uri
    end

    def connect(object, method, data)
      # see https://github.com/cpuguy83/rails_otrs
      uri = get_ticket_json_uri

      # credentials
      user = URI.encode @conference.ticket_server.user
      password = URI.encode @conference.ticket_server.password
      uri.query = "User=#{user}"
      uri.query += "&Password=#{password}"

      # otrs api
      uri.query += "&Object=#{object}"
      uri.query += "&Method=#{method}"
      data = URI.encode(data.to_json)
      data = URI.escape(data, '=\',\\/+-&?#.;')
      uri.query += "&Data=#{data}"

      if $DEBUG
        @logger.info "[ === ] #{object}::#{method}"
        @logger.info uri.to_s 
      end

      if @test_only
        @logger.info uri.request_uri
        return Array.new
      end

      # https connection
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      result = ActiveSupport::JSON::decode(response.body)
      if result["Result"] == 'successful'
          result["Data"]
      else
        @logger.info response.to_json
        raise "OTRS Error:#{result["Result"]} #{result["Data"]} #{result["Message"]}"
      end
    end

  end

  def create_ticket_title( prefix, event )
    "#{prefix} '#{event.title.truncate(30)}'"
  end

  def create_ticket_requestors( people )
    people.collect { |p|
      name = "#{p.first_name} #{p.last_name}"
      name.gsub!(/,/, '')
      { name: name, email: p.email }
    }
  end

  #
  # connect to a remote ticket system and return remote_id
  #
  def create_remote_ticket( args = {} )
    args.reverse_update(body: '', test_only: false)
    @conference = args[:conference]

    otrs = OtrsAdapter.new( @conference, Rails.logger )
    otrs.test_only = args[:test_only]

    data = otrs.connect( 'UserObject', 'GetUserData', { User: @conference.ticket_server.user })
    user_data = Hash[*data]

    data = otrs.connect( 'UserObject', 'GetUserData', { UserEmail: args[:owner_email] })
    owner_data = Hash[*data]

    from = args[:owner_email]
    unless args[:requestors].empty?
      from = args[:requestors].collect { |r| "#{r[:name]} <#{r[:email]}>" }.join(', ')
    end

    remote_ticket_id = otrs.connect( 'TicketObject', 'TicketCreate', {
        Title: args[:title],
        Queue: @conference.ticket_server.queue,
        Lock: 'unlock',
        Priority: '3 normal',
        State: 'new',
        CustomerUser: from,
        OwnerID: owner_data['UserID'],
        UserID: user_data['UserID']
    }).first

    remote_article_id = otrs.connect( 'TicketObject', 'ArticleCreate', {
      TicketID: remote_ticket_id,
      ArticleType: 'webrequest',
      SenderType: 'customer',
      HistoryType: "WebRequestCustomer",
      HistoryComment: "created from frab",
      From: from,
      Subject: args[:title],
      ContentType: 'text/plain; charset=ISO-8859-1',
      Body: args[:body],
      UserID: user_data['UserID'],
      Loop: 0,
    }).first

    remote_ticket_id
  end


end

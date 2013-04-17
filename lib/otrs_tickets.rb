module OtrsTickets
  #
  #  Rails Views
  #
  module Helper
    def Helper.get_ticket_view_url( conference, remote_id=0 )
      return if conference.ticket_server.nil?
      return unless remote_id.is_a? Fixnum
      uri = URI.parse(conference.ticket_server.url)
      uri.path += 'index.pl'
      uri.query = "Action=AgentTicketZoom;TicketID=#{remote_id}"
      uri.to_s
    end
  end

  #
  # Otrs Server
  #
  class OtrsAdapter
    require 'savon'
    NAMESPACE = "urn:frab"
    ENDPOINT = 'nph-genericinterface.pl/Webservice/frab'

    def initialize(c, l)
      @conference = c
      @logger = l
      @test_only = false
    end
    attr_accessor :test_only

    def get_endpoint
      uri = URI(@conference.ticket_server.url)
      uri.path += ENDPOINT
      uri
    end

    def connect
      uri = get_endpoint

      # credentials
      user = URI.encode @conference.ticket_server.user
      password = URI.encode @conference.ticket_server.password

      # soap connection
      @client = Savon.client do
        endpoint uri
        namespace NAMESPACE
        # FIXME still needs wsdl with configured endpoint, I don't want a tempfile :(
        #wsdl 'config/otrs.wsdl'
        ssl_verify_mode :none
        soap_version 2
        log_level :info
      end

      if @test_only
        @logger.info @client.to_yaml
        return
      end

      begin
        response = @client.call(:session_create, soap_action: "SessionCreate") do
          message 'UserLogin' => USER, 'Password' => PW
        end
      rescue => ex
        @client = nil
        raise "OTRS ERROR: #{ex.message}"
      end

      unless response.http.code == 200
        raise "OTRS Connection Error: #{response.http.code}"
      end

      unless response.hash[:envelope][:body][:session_create_response].has_key?(:session_id)
        raise response.hash[:envelope][:body][:session_create_response][:error][:error_message]
      end
      @session_id = response.hash[:envelope][:body][:session_create_response][:session_id]
    end

    def call(method, data)

      if @test_only
        @logger.info method, data
        return
      end

      begin
        response = client.call(method) do
          message data
        end
      rescue => ex
        @client = nil
        raise "OTRS ERROR: #{ex.message}"
      end

      unless response.http.code == 200
        raise "OTRS Connection Error: #{response.http.code}"
      end

      response.hash[:envelope][:body]
    end

  end

  def OtrsTickets.create_ticket_title( prefix, event )
    "#{prefix} '#{event.title.truncate(30)}'"
  end

  def OtrsTickets.create_ticket_requestors( people )
    people.collect { |p|
      name = "#{p.first_name} #{p.last_name}"
      name.gsub!(/,/, '')
      { name: name, email: p.email }
    }
  end

  #
  # connect to a remote ticket system and return remote_id
  #
  def OtrsTickets.create_remote_ticket( args = {} )
    args.reverse_update(body: '', test_only: false)
    @conference = args[:conference]

    otrs = OtrsAdapter.new( @conference, Rails.logger )
    otrs.test_only = args[:test_only]

    # create session
    otrs.connect

    from = args[:owner_email]
    to = from
    unless args[:requestors].empty?
      from = args[:requestors].collect { |r| "#{r[:name]} <#{r[:email]}>" }.join(', ')
    end


    ticket = {
      'Title' => args[:title],
      'Queue' => @conference.ticket_server.queue,
      'Lock' => 'unlock',
      'Priority' => '3 normal',
      'State' => 'new',
      'CustomerUser' => from,
      'OwnerID' => 1,
      'From' => from,
      'To' => to,
    }

    article = {
      'ArticleType' => 'webrequest',
      #
      'SenderType' => 'customer',
      'Loop' => 0,
      'NoAgentNotify'    => 0,
      'AutoResponseType' => 'auto reply',
      #
      'HistoryType' => "WebRequestCustomer",
      'HistoryComment' => "created from frab",
      'ContentType' => 'text/plain; charset=ISO-8859-1',
      'Subject' => args[:title],
      'Body' => args[:body],
      'From' => from,
      'To' => to,
    }

    response = otrs.call(:ticket_create, 
              { 'SessionID' => @session_id, 'Ticket' => ticket, 'Article' => article })

    # FIXME extract ticket id from hash
    response[:ticket_create_response]
  end

end

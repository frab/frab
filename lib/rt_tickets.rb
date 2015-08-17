module RTTickets
  #
  # Rails Views
  #
  module Helper
    def self.get_ticket_view_url(conference, remote_id = '0')
      return if conference.ticket_server.nil?
      uri = URI.parse(conference.ticket_server.url)
      uri.path += 'Ticket/Display.html'
      uri.query = "id=#{remote_id}"
      uri.to_s
    end
  end

  #
  # RT Server
  #
  class RTAdapter
    require 'uri'
    require 'net/http'

    def initialize(c, l)
      @conference = c
      @logger = l
      @test_only = false
    end
    attr_accessor :test_only

    def create(data)
      @uri = URI.parse(@conference.ticket_server.url)
      @user = URI.encode @conference.ticket_server.user
      @password = URI.encode @conference.ticket_server.password
      @uri.path += 'REST/1.0/ticket/new'

      if @test_only
        @logger.info @uri.path
        @logger.info "content => #{data}"
        return
      end

      request = Net::HTTP::Post.new(@uri.path)
      request.set_form_data('user' => @user, 'pass' => @password, 'content' => data)
      http = get_http(@uri)
      response = http.request(request)

      case response
      when Net::HTTPSuccess
        if response.body.match(/200 Ok/) and m = response.body.match(/Ticket (\d+) created./)
          return m[1]
        else
          @logger.info response.to_json
          fail "RT Error: #{response.body}"
        end
      else
        @logger.info response.to_json
        fail "RT HTTP Error: #{response.error!}"
      end
    end

    protected

    def get_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.is_a? URI::HTTPS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end
  end

  def self.create_ticket_title(prefix, event)
    "#{prefix} '#{event.title.truncate(30)}'"
  end

  def self.create_ticket_requestors(people)
    people.collect { |p|
      name = "#{p.first_name} #{p.last_name}"
      name.delete!(',')
      { name: name, email: p.email }
    }
  end

  #
  # connect to a remote ticket system and return remote_id
  #
  def self.create_remote_ticket(args = {})
    args.reverse_update(body: '', test_only: false)
    @conference = args[:conference]

    ticket_system = RTAdapter.new(@conference, Rails.logger)
    ticket_system.test_only = args[:test_only]

    data = <<-EOF
id: ticket/new
Queue: #{@conference.ticket_server.queue}
Subject:  #{args[:title]}
Requestor: #{args[:owner_email]}
    EOF

    args[:requestors].each { |r|
      data << "Requestor: #{r[:name]} <#{r[:email]}>"
    }

    remote_ticket_id = ticket_system.create(data)
    remote_ticket_id
  end
end

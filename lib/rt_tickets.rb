module RTTickets
  #
  # Rails Views
  #
  module Helper
    def Helper.get_ticket_view_url( conference, remote_id='0' )
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
      @cookie = nil
      @test_only = false
    end
    attr_accessor :test_only

    def login
      @uri = URI.parse(@conference.ticket_server.url)
      @user = URI.encode @conference.ticket_server.user
      @password = URI.encode @conference.ticket_server.password

      if @test_only
        @logger.info @uri.path
        @logger.info "user => #{@user}, pass => 'XXX'"
        return
      end

      request = Net::HTTP::Post.new(@uri.path)
      request.set_form_data( { 'user' => @user, 'pass' => @password } )

      response = Net::HTTP.start(@uri.host, @uri.port) {|http| http.request(request) }
      case response
      when Net::HTTPSuccess
        @cookie = response['set-cookie'].split(/;/).first
      else
        @logger.info response.to_json
        raise "RT Login Failed: #{response.error!}"
      end
    end

    def create(data)
      @uri = URI.parse(@conference.ticket_server.url)
      @uri.path += 'REST/1.0/ticket/new'

      if @test_only
        @logger.info @uri.path
        @logger.info "content => #{data}"
        return
      end

      request = Net::HTTP::Post.new(@uri.path)
      request.add_field('Cookie', @cookie)
      request.set_form_data({ 'content' => data })

      response = Net::HTTP.start(@uri.host, @uri.port) {|http| 
        # SSL
        #http.use_ssl = true
        #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.request(request) 
      }
      case response
      when Net::HTTPSuccess
        if response.body.match(/200 Ok/) and m = response.body.match(/Ticket (\d+) created./)
          return m[1]
        else
          @logger.info response.to_json
          raise "RT Error: #{response.body}"
        end
      else
        @logger.info response.to_json
        raise "RT HTTP Error: #{response.error!}"
      end
    end
  end

  def RTTickets.create_ticket_title( prefix, event )
    "#{prefix} '#{event.title.truncate(30)}'"
  end

  def RTTickets.create_ticket_requestors( people )
    people.collect { |p|
      name = "#{p.first_name} #{p.last_name}"
      name.gsub!(/,/, '')
      { name: name, email: p.email }
    }
  end

  #
  # connect to a remote ticket system and return remote_id
  #
  def RTTickets.create_remote_ticket( args = {} )
    args.reverse_update(body: '', test_only: false)
    @conference = args[:conference]

    ticket_system = RTAdapter.new( @conference, Rails.logger )
    ticket_system.test_only = args[:test_only]
    ticket_system.login

    data = <<-EOF
id: ticket/new
Queue: #{@conference.ticket_server.queue}
Subject:  #{args[:title]}
Requestor: #{args[:owner_email]}
    EOF

    args[:requestors].each { |r| 
      data << "Requestor: #{r[:name]} <#{r[:email]}>"
    }

    remote_ticket_id = ticket_system.create( data ) 
    remote_ticket_id
  end


end


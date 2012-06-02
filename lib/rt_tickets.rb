module RTTickets
  #
  # Rails Views
  #
  module Helper
    def get_ticket_view_url( remote_id='0' )
      uri = URI.parse(@conference.ticket_server.url)
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
    end

    def login
      @uri = URI.parse(@conference.ticket_server.url)
      @user = URI.encode @conference.ticket_server.user
      @password = URI.encode @conference.ticket_server.password

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

  def create_ticket_title( prefix, event )
    "#{prefix} '#{event.title.truncate(30)}'"
  end

  def create_ticket_requestors( people )
    people.collect { |p|
      name = "#{p.first_name} #{p.last_name}"
      name.gsub!(/,/, '')
      { :name => name, :email => p.email }
    }
  end

  #
  # connect to a remote ticket system and return remote_id
  #
  def create_remote_ticket( conference, title, requestors, owner_email, body='' ) 
    @conference = conference
    ticket_system = RTAdapter.new( @conference, Rails.logger )

    ticket_system.login

    data = <<-EOF
id: ticket/new
Queue: #{@conference.ticket_server.queue}
Subject:  #{title}
Requestor: #{owner_email}
    EOF

    requestors.each { |r| 
      data << "Requestor: #{r[:name]} <#{r[:email]}>"
    }

    remote_ticket_id = ticket_system.create( data ) 
    remote_ticket_id
  end


end


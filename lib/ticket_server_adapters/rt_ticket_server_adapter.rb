class RTTicketServerAdapter < TicketServerAdapter
  require 'uri'
  require 'net/http'

  def get_ticket_view_url(remote_id)
    uri = URI.parse(@server.url)
    uri.path += 'Ticket/Display.html'
    uri.query = "id=#{remote_id}"
    uri.to_s
  end

  #
  # connect to a remote ticket system and return remote_id
  #
  def create_remote_ticket(args)
    data = <<-EOF
id: ticket/new
Queue: #{@server.queue}
Subject:  #{args[:title]}
Requestor: #{args[:owner_email]}
    EOF

    args[:requestors].each do |r|
      data << "Requestor: #{r[:name]} <#{r[:email]}>"
    end

    remote_ticket_id = create(data)
    remote_ticket_id
  end

  private

  def get_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.is_a? URI::HTTPS
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http
  end

  def create(data)
    uri = URI.parse(@server.url)
    user = URI.encode(@server.user)
    password = URI.encode(@server.password)
    uri.path += 'REST/1.0/ticket/new'

    if @test_only
      @logger.info uri.path
      @logger.info "content => #{data}"
      return
    end

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data('user' => user, 'pass' => password, 'content' => data)
    http = get_http(uri)
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

end
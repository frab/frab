class RTTicketServerAdapter < TicketServerAdapter
  require 'rubygems'
  require 'roust'

  def get_ticket_view_url(remote_id)
    uri = URI.parse(@server.url)
    uri.path += 'Ticket/Display.html'
    uri.query = "id=#{remote_id}"
    uri.to_s
  end

  def create_remote_ticket(args)
    rt = Roust.new({
                     :server   => @server.url,
                     :username => @server.user,
                     :password => @server.password
                   },
                   {
                     'Referer' => @server.url
                   })
    fail "RT Error" if not rt.authenticated?

    ticket = rt.ticket_create({
                                'Subject'    => args[:title],
                                'Queue'      => @server.queue,
                                'Owner'      => 'Nobody',
                                'Requestors' => args[:requestors].collect { |r| "#{r[:name]} <#{r[:email]}>" },
                              })

    ticket['id']
  end

end

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

    begin
      rt.ticket_comment(ticket['id'], { 'Action' => 'comment', 'Text' => args[:owner_email] + ' created a ticket for ' + args[:frab_url] } )
    rescue Exception => ex
      Rails.logger.debug 'RT error ' + ex.to_s + ' when adding frab url'
    end

    ticket['id']
  end

  def add_correspondence(remote_id, subject, body, recipient)
    rt = Roust.new({
            :server   => @server.url,
            :username => @server.user,
            :password => @server.password
            }, {
            'Referer' => @server.url
            })
    fail "RT Error" if not rt.authenticated?

    old_ticket = rt.show(remote_id)
    attrs = { 'Subject' => subject }
    attrs['Requestors'] = [ recipient ] if recipient
    rt.ticket_update(remote_id, attrs )
    begin
      rt.ticket_comment(remote_id, { 'Action' => 'correspond', 'Text' => body })
    rescue UnhandledResponse => ur
      ex = ur unless /^# Correspondence added/.match(ur.to_s)
    rescue Exception => ex
      Rails.logger.debug 'RT reported an error'
      Rails.logger.debug ex.to_s
    end
    # XXX needs to go into an ensure block
    rt.ticket_update(remote_id, old_ticket.slice( 'Subject', 'Requestors' ))

    raise ex if ex
  end

end

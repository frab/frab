module OtrsTickets

  def create_ticket_title( event )
    title = event.title[0..30]
    "#{event.id}: #{title}"
  end

  def create_ticket_requestors( people )
    people.collect { |p|
      { :name => "#{p.first_name} #{p.last_name}", :email => p.email }
    }
  end

  def create_remote_ticket( title, requestors, owner, body='' ) 
    # connect to remote api and create this ticket
    logger.info("[ === ] TITLE " + title)
    logger.info("[ === ] REQUESTORS " + requestors.to_s)
    logger.info("[ === ] OWNER " + owner)
    # TODO connect to a remote ticket system
    ""
  end

  module Helper
    def get_ticket_url( remote_id='0' )
      "#{@conference.ticket_server.url}/#{remote_id}"
    end
  end

end

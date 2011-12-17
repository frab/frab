class TicketsController < ApplicationController
  include OtrsTickets

  before_filter :authenticate_user!
  before_filter :require_admin

  def create
    @event = Event.find(params[:event_id])
    remote_id = create_remote_ticket( 
                                     create_ticket_title( @event ), 
                                     create_ticket_requestors( @event.people ),
                                     @current_user.email
                                    )
    if (@event.ticket.nil?)
      @event.ticket = Ticket.new
    end
    @event.ticket.remote_ticket_id = remote_id
    @event.save
    redirect_to event_path( :id => params[:event_id], :method => :get )
  end

end

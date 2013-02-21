class TicketsController < ApplicationController
  if Rails.configuration.ticket_server_type == 'otrs_ticket'
    include OtrsTickets
  else
    include RTTickets
  end

  before_filter :authenticate_user!

  def create
    @event = Event.find(params[:event_id])
    authorize! :manage, @event
    if @conference.ticket_server.nil?
      redirect_to edit_conference_path(conference_acronym: @conference.acronym), alert: "No ticket server configured"
      return
    end

    remote_id = create_remote_ticket(conference: @conference,
                                     title: create_ticket_title(
                                       t(:your_submission, locale: @event.language),
                                       @event),
                                     requestors: create_ticket_requestors(@event.speakers),
                                     owner_email: current_user.email,
                                     test_only: params[:test_only])
    if (@event.ticket.nil?)
      @event.ticket = Ticket.new
    end
    @event.ticket.remote_ticket_id = remote_id
    @event.save
    redirect_to event_path(id: params[:event_id], method: :get)
  end

end

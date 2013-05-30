class TicketsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

  def create
    @event = Event.find(params[:event_id])
    authorize! :manage, @event

    if not @conference.is_ticket_server_enabled? or @conference.ticket_server.nil?
      redirect_to edit_conference_path(conference_acronym: @conference.acronym), alert: "No ticket server configured"
      return
    end
    server = @conference.get_ticket_module

    begin
      remote_id = server.create_remote_ticket(conference: @conference,
                                     title: server.create_ticket_title(
                                       t(:your_submission, locale: @event.language),
                                       @event),
                                     requestors: server.create_ticket_requestors(@event.speakers),
                                     owner_email: current_user.email,
                                     test_only: params[:test_only])
    rescue => ex
      redirect_to event_path(id: params[:event_id], method: :get), alert: "Failed to create ticket: #{ex.message}"
      return
    end

    if remote_id.nil?
      redirect_to event_path(id: params[:event_id], method: :get) , alert: "Failed to receive remote id"
      return
    end

    @event.ticket = Ticket.new if @event.ticket.nil?
    @event.ticket.remote_ticket_id = remote_id
    @event.save
    redirect_to event_path(id: params[:event_id], method: :get)
  end

end

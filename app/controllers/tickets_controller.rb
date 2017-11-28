class TicketsController < BaseConferenceController
  before_action :manage_only!
  before_action :check_ticket_server

  def create_event
    @event = Event.find(params[:id])
    server = @conference.ticket_server

    begin
      title = t(:your_submission, locale: @event.language) + ' ' + @event.title.truncate(30)
      remote_id = server.create_remote_ticket(title: title,
                                              requestors: server.create_ticket_requestors(@event.speakers),
                                              owner_email: current_user.email,
                                              frab_url: event_url(@event),
                                              test_only: params[:test_only])
    rescue => ex
      return redirect_to event_path(id: params[:id], method: :get), alert: t('tickets.error_failed_to_create', {message: ex.message})
    end

    if remote_id.nil?
      return redirect_to event_path(id: params[:id], method: :get), alert: t('tickets.error_failed_to_receive_id')
    end

    @event.ticket = Ticket.new if @event.ticket.nil?
    @event.ticket.remote_ticket_id = remote_id
    @event.save
    redirect_to event_path(id: params[:id], method: :get)
  end

  def create_person
    @person = Person.find(params[:id])
    server = @conference.ticket_server

    begin
      remote_id = server.create_remote_ticket(title: @person.full_name,
                                              requestors: @person.email,
                                              owner_email: current_user.email,
                                              frab_url: person_url(@person),
                                              test_only: params[:test_only])
    rescue => ex
      return redirect_to person_path(id: params[:id], method: :get), alert: t('tickets.error_failed_to_create', {message: ex.message})
    end

    if remote_id.nil?
      return redirect_to person_path(id: params[:id], method: :get), alert: t('tickets.error_failed_to_receive_id')
    end

    @person.ticket = Ticket.new if @person.ticket.nil?
    @person.ticket.remote_ticket_id = remote_id
    @person.save
    redirect_to person_path(id: params[:id], method: :get)
  end

  private

  def check_ticket_server
    return if @conference.ticket_server && @conference.ticket_server_enabled?
    redirect_to edit_conference_path(conference_acronym: @conference.acronym), alert: t('tickets.error_no_ticket_server')
  end
end

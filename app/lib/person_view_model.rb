class PersonViewModel
  def initialize(person, conference)
    @person = person
    @conference = conference
    @redact = false
  end

  def redact_events!
    @redact = true
  end

  def current_events
    return [] unless @conference
    return @current_events if @current_events
    @current_events = @person.events_as_presenter_in(@conference)
    @current_events.to_a.map!(&:clean_event_attributes!) if @redact
    @current_events
  end

  def other_events
    return [] unless @conference
    return @other_events if @other_events
    @other_events = @person.events_as_presenter_not_in(@conference)
    @other_events.to_a.map!(&:clean_event_attributes!) if @redact
    @other_events
  end

  def availabilities
    return unless @conference
    @availabilities ||= @person.availabilities.where("conference_id = #{@conference.id}")
  end

  def expenses
    return unless @conference
    @expenses = @person.expenses.where(conference_id: @conference.id)
  end

  def expenses_sum_reimbursed
    return unless @conference
    @expenses_sum_reimbursed ||= @person.sum_of_expenses(@conference, true)
  end

  def expenses_sum_non_reimbursed
    return unless @conference
    @expenses_sum_non_reimbursed ||= @person.sum_of_expenses(@conference, false)
  end

  def transport_needs
    return unless @conference
    @transport_needs ||= @person.transport_needs.where(conference_id: @conference.id)
  end

  def can_add_ticket?
    @conference&.ticket_server_enabled? && !@person.remote_ticket?
  end

  def show_expenses?
    @conference&.expenses_enabled? && expenses.any?
  end

  def show_transports?
    @conference&.transport_needs_enabled? && transport_needs.any?
  end

  def remote_ticket_present?
    @person&.ticket&.remote_ticket_id
  end
end

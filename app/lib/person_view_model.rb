class PersonViewModel
  def initialize(current_user, person, conference)
    @current_user = current_user
    @person = person
    @conference = conference
  end

  def redact_events?
    @redact ||= !Pundit.policy(@current_user, @conference).manage?
  end

  def current_events
    return @current_events if @current_events
    @current_events = @person.events_as_presenter_in(@conference)
    @current_events.to_a.map!(&:clean_event_attributes!) if redact_events?
    @current_events
  end

  def other_events
    return @other_events if @other_events
    @other_events = @person.events_as_presenter_not_in(@conference)
    @other_events.to_a.map!(&:clean_event_attributes!) if redact_events?
    @other_events
  end

  def availabilities
    @availabilities ||= @person.availabilities.where("conference_id = #{@conference.id}")
  end

  def expenses
    @expenses = @person.expenses.where(conference_id: @conference.id)
  end

  def expenses_sum_reimbursed
    @expenses_sum_reimbursed ||= @person.sum_of_expenses(@conference, true)
  end

  def expenses_sum_non_reimbursed
    @expenses_sum_non_reimbursed ||= @person.sum_of_expenses(@conference, false)
  end

  def transport_needs
    return unless @conference
    @transport_needs ||= @person.transport_needs.where(conference_id: @conference.id)
  end

  def can_add_ticket?
    @conference.ticket_server_enabled? && !@person.remote_ticket?
  end

  def show_expenses?
    @conference.expenses_enabled? && expenses.any?
  end

  def show_transports?
    @conference.transport_needs_enabled? && transport_needs.any?
  end

  def remote_ticket_present?
    @person&.ticket&.remote_ticket_id
  end
end

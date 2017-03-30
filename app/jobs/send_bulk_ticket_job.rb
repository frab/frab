class SendBulkTicketJob
  include SuckerPunch::Job

  def perform(conference, filter)
    Rails.logger.debug 'performing ' + filter + ' on ' + conference.acronym
    case filter
    when 'accepting'
      conference.events.where(state: filter).map(&:notify!)
    when 'rejecting'
      conference.events.where(state: filter).map(&:notify!)
    when 'confirmed'
      conference.events.where(state: filter).scheduled.map(&:notify!)
    end
  end
end

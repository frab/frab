class SendBulkTicketJob
  include SuckerPunch::Job

  def perform(conference, filter)
    Rails.logger.debug 'performing ' + filter + ' on ' + conference.acronym
    case filter
    when 'accepting'
      conference.events.where(state: filter).map{|e| e.notify! }
    when 'rejecting'
      conference.events.where(state: filter).map{|e| e.notify! }
    when 'confirmed'
      conference.events.where(state: filter).scheduled.map{|e| e.notify! }
    end

  end
end

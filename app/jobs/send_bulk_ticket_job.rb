class SendBulkTicketJob
  include SuckerPunch::Job

  def perform(conference, filter)

    case filter
    when 'accept'
      conference.events.where(state: :accepting).map{|e| e.notify }
    when 'reject'
      conference.events.where(state: :rejecting).map{|e| e.notify }
    when 'schedule'
      conference.events.where(state: :confirmed).scheduled.map{|e| e.notify }
    end

  end
end

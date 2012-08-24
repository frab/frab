class EventFeedbacksController < FrabApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin

  def index
    @event = Event.find(params[:event_id])
    @event_feedbacks = @event.event_feedbacks
  end

end

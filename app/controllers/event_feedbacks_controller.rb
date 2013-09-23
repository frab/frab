class EventFeedbacksController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

  def index
    authorize! :read, EventFeedback
    @event = Event.find(params[:event_id])
    @event_feedbacks = @event.event_feedbacks
  end

end

class EventFeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def index
    authorize! :access, :event_feedback
    @event = Event.find(params[:event_id])
    @event_feedbacks = @event.event_feedbacks
  end
end

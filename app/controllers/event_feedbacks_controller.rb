class EventFeedbacksController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :event_feedback, :parent => false

  def index
    @event = Event.find(params[:event_id])
    @event_feedbacks = @event.event_feedbacks
  end

end

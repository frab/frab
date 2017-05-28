class EventFeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  after_action :verify_authorized

  def index
    authorize Conference, :index?
    @event = Event.find(params[:event_id])
    @event_feedbacks = @event.event_feedbacks
  end
end

class Public::FeedbackController < ApplicationController
  layout "public_schedule"

  def new
    @event = @conference.events.find(params[:event_id])
    @feedback = EventFeedback.new
    @feedback.rating = 3
  end

  def create
    @event = @conference.events.find(params[:event_id])
    @feedback = @event.event_feedbacks.new(event_feedback_params)

    if @feedback.save
      render action: "thank_you"
    else
      render action: "new"
    end
  end

  private

  def event_feedback_params
    params.require(:event_feedback).permit(:rating, :comment)
  end
end

class Public::FeedbackController < ApplicationController

  layout "public_schedule"

  def new
    @event = @conference.events.find(params[:event_id])
    @feedback = EventFeedback.new
    @feedback.rating = 3
  end

  def create
    @event = @conference.events.find(params[:event_id])
    @feedback = @event.event_feedbacks.new(params[:event_feedback])
    
    if @feedback.save
      render action: "thank_you"
    else
      render action: "new"
    end
  end

end

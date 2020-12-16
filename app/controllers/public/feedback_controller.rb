class Public::FeedbackController < ApplicationController
  layout 'public_schedule'
  before_action :find_event

  def new
    @feedback = EventFeedback.new
    @feedback.rating = 3
  end

  def create
    @feedback = @event.event_feedbacks.new(event_feedback_params)

    respond_to do |format|
      if @feedback.save
        format.html { render action: 'thank_you' }
        format.json { head :ok, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # filter events valid for feedback
  def find_event
    @event = @conference.events.is_public.accepted.scheduled.find(params[:event_id])
  end

  def event_feedback_params
    params.require(:event_feedback).permit(:rating, :comment)
  end
end

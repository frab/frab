class Public::FeedbackController < ApplicationController
  layout 'public_schedule'

  def new
    @event = @conference.events.find(params[:event_id])
    @feedback = EventFeedback.new
    @feedback.rating = 3
  end

  def create
    @event = @conference.events.find(params[:event_id])
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

  def event_feedback_params
    params.require(:event_feedback).permit(:rating, :comment)
  end
end

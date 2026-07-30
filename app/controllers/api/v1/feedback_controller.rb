class Api::V1::FeedbackController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_by_token!
  before_action :check_feedback_enabled!

  def create
    event = find_event(params[:event_id])
    return head :not_found unless event

    feedback = event.event_feedbacks.new(create_params)
    if feedback.save
      head :created
    else
      render json: { errors: feedback.errors.full_messages }, status: :unprocessable_content
    end
  end

  def batch
    ratings = batch_params[:ratings]
    unless ratings.is_a?(Array) && ratings.any?
      return render json: { error: 'ratings must be a non-empty array' }, status: :unprocessable_content
    end

    results = ratings.map { |entry| process_single(entry) }
    errors = results.select { |r| r[:error] }

    if errors.any?
      render json: { created: results.count { |r| r[:ok] }, errors: errors }, status: :multi_status
    else
      render json: { created: results.size }, status: :created
    end
  end

  private

  def authenticate_by_token!
    authenticate_with_http_token do |token, _options|
      next false if token.blank?

      conference = Conference.find_by(acronym: params[:conference_acronym])
      if conference && ActiveSupport::SecurityUtils.secure_compare(conference.feedback_token.to_s, token)
        @conference = conference
        true
      else
        false
      end
    end || head(:unauthorized)
  end

  def check_feedback_enabled!
    head :forbidden unless @conference&.feedback_enabled?
  end

  def find_event(event_id)
    @conference.events.is_public.accepted.scheduled.find_by(id: event_id)
  end

  def process_single(entry)
    event = find_event(entry[:event_id])
    return { error: "event #{entry[:event_id]} not found" } unless event

    feedback = event.event_feedbacks.new(rating: entry[:rating], comment: entry[:comment])
    if feedback.save
      { ok: true }
    else
      { error: "event #{entry[:event_id]}: #{feedback.errors.full_messages.join(', ')}" }
    end
  end

  def create_params
    params.permit(:rating, :comment)
  end

  def batch_params
    params.permit(ratings: [:event_id, :rating, :comment])
  end
end

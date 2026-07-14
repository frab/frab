class Api::V1::FeedbackController < ActionController::API
  before_action :authenticate_by_token!
  before_action :check_feedback_enabled!

  def create
    event = find_event(params[:event_id])
    return head :not_found unless event

    feedback = event.event_feedbacks.new(rating: params[:rating], comment: params[:comment])
    if feedback.save
      head :created
    else
      render json: { errors: feedback.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def batch
    ratings = params[:ratings]
    unless ratings.is_a?(Array) && ratings.any?
      return render json: { error: 'ratings must be a non-empty array' }, status: :unprocessable_entity
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
    token = bearer_token || params[:token]
    conference = Conference.find_by(acronym: params[:conference_acronym], feedback_token: token)
    return head :unauthorized unless conference
    @conference = conference
  end

  def check_feedback_enabled!
    head :forbidden unless @conference.feedback_enabled?
  end

  def bearer_token
    header = request.headers['Authorization']
    header&.start_with?('Bearer ') ? header.sub('Bearer ', '') : nil
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
end

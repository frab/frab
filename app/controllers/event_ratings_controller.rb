class EventRatingsController < BaseConferenceController
  before_action :find_event
  before_action :crew_only!

  def show
    @rating = @event.event_ratings.find_by(person_id: current_user.person.id) || EventRating.new
    setup_batch_reviews_next_event
  end

  def create
    # only one rating allowed, if one exists update instead
    return update if @event.event_ratings.find_by(person_id: current_user.person.id)

    @rating = new_event_rating
    if @rating.save
      redirect_to event_event_rating_path, notice: t('ratings_module.notice_rating_created')
    else
      flash[:alert] = t('ratings_module.error_creating', {error:  @rating.errors.full_messages.join})
      render action: 'show'
    end
  end

  def update
    @rating = @event.event_ratings.find_by!(person_id: current_user.person.id)
    
    if params[:delete_rating]
      @rating.delete
      redirect_to event_event_rating_path, notice: t('ratings_module.notice_rating_deleted')
    elsif @rating.update_attributes(event_rating_params)
      redirect_to event_event_rating_path, notice: t('ratings_module.notice_rating_updated')
    else
      flash[:alert] = t('ratings_module.error_updating')
      render action: 'show'
    end
  end

  protected

  def setup_batch_reviews_next_event
    return unless session[:review_ids]
    current_index = session[:review_ids].index(@event.id)
    return unless current_index
    return if session[:review_ids].last == @event.id
    @next_event = Event.find(session[:review_ids][current_index + 1])
  end

  def new_event_rating
    rating = EventRating.new(event_rating_params)
    rating.event = @event
    rating.person = current_user.person
    rating
  end

  # filter according to users abilities
  def find_event
    @event = Event.find(params[:event_id])
    @event_ratings = policy_scope(@event.event_ratings)
  end

  def event_rating_params
    params.require(:event_rating).permit(:rating, :comment, :text)
  end
end

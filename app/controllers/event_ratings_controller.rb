class EventRatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  before_action :find_event

  def show
    authorize! :read, EventRating
    @rating = @event.event_ratings.find_by_person_id(current_user.person.id) || EventRating.new
    if session[:review_ids] and current_index = session[:review_ids].index(@event.id) and session[:review_ids].last != @event.id
      @next_event = Event.find(session[:review_ids][current_index + 1])
    end
  end

  def create
    # only one rating allowed, if one exists update instead
    if @event.event_ratings.find_by_person_id(current_user.person.id)
      update
      return
    end
    @rating = EventRating.new(event_rating_params)
    @rating.event = @event
    @rating.person = current_user.person
    authorize! :create, @rating

    if @rating.save
      redirect_to event_event_rating_path, notice: "Rating saved successfully."
    else
      flash[:alert] = "Failed to create event rating"
      render action: "show"
    end
  end

  def update
    @rating = @event.event_ratings.find_by_person_id(current_user.person.id)
    authorize! :update, @rating

    if @rating.update_attributes(event_rating_params)
      redirect_to event_event_rating_path, notice: "Rating updated successfully."
    else
      flash[:alert] = "Failed to update event rating"
      render action: "show"
    end
  end

  protected

  # filter according to users abilities
  def find_event
    @event = Event.find(params[:event_id])
    return if @event_ratings
    @event_ratings = @event.event_ratings.accessible_by(current_ability)
  end

  def event_rating_params
    params.require(:event_rating).permit(:rating, :comment, :text)
  end
end

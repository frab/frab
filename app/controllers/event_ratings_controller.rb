class EventRatingsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_event

  def show
    authorize! :read, EventRating
    @rating = @event.event_ratings.find_by_person_id(current_user.person.id) || EventRating.new
    if session[:review_ids] and current_index = session[:review_ids].index(@event.id) and session[:review_ids].last != @event.id
      @next_event = Event.find(session[:review_ids][current_index + 1])
    end
  end

  def create
    @rating = EventRating.new(params[:event_rating])
    @rating.event = @event
    @rating.person = current_user.person
    authorize! :manage, @rating
    @rating.save
    redirect_to event_event_rating_path, notice: "Rating saved successfully."
  end

  def update
    @rating = @event.event_ratings.find_by_person_id(current_user.person.id)
    authorize! :manage, @rating
    @rating.update_attributes(params[:event_rating])
    redirect_to event_event_rating_path, notice: "Rating saved successfully."
  end

  protected

  # filter according to users abilities
  def find_event
    @event = Event.find(params[:event_id])
    if @event_ratings.nil?
      @event_ratings = @event.event_ratings.accessible_by(current_ability)
    end
  end

end

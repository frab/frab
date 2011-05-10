class EventRatingsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin
  before_filter :find_event

  def show
    @rating = @event.event_ratings.find_by_person_id(current_user.person.id) || EventRating.new
  end

  def create
    @rating = EventRating.new(params[:event_rating])
    @rating.event = @event
    @rating.person = current_user.person
    @rating.save
    redirect_to event_event_rating_path, :notice => "Rating saved successfully."
  end

  def update
    @rating = @event.event_ratings.find_by_person_id(current_user.person.id)
    @rating.update_attributes(params[:event_rating])
    redirect_to event_event_rating_path, :notice => "Rating saved successfully."
  end

  protected

  def find_event
    @event = Event.find(params[:event_id])
  end

end

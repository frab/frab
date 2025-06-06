class EventPeopleController < ApplicationController
  before_action :set_event_person

  def move_up
    @event_person.move_higher
    redirect_back fallback_location: edit_people_event_path(@event_person.event)
  end

  def move_down
    @event_person.move_lower
    redirect_back fallback_location: edit_people_event_path(@event_person.event)
  end

  private

  def set_event_person
    @event_person = EventPerson.find(params[:id])
  end
end
class Public::ScheduleController < ApplicationController

  def index
    @days = @conference.days

    respond_to do |format|
      format.html
      format.xml
      format.xcal
      format.ics
    end
  end

  def day
  end

  def events
    @events = @conference.events.public.accepted
  end

  def event
    @event = @conference.events.public.accepted.find(params[:id])
  end

  def speakers
    @speakers = Person.publicly_speaking_at(@conference)
  end

  def speaker
    @speaker = Person.publicly_speaking_at(@conference).find(params[:id])
  end

end

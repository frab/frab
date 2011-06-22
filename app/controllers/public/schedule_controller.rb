class Public::ScheduleController < ApplicationController

  layout 'public_schedule'

  def index
    @days = @conference.days

    respond_to do |format|
      format.html
      format.xml
      format.xcal
      format.ics
    end
  end

  def style
  end

  def day
    @day = Date.parse(params[:date])
    @day_index = @conference.days.index(@day) + 1
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

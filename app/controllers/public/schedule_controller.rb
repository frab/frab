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
    @rooms = @conference.rooms.public.all
    @events = Hash.new
    @skip_row = Hash.new
    @rooms.each do |room|
      @events[room] = room.events.accepted.public.scheduled_on(@day).order(:start_time).all
      @skip_row[room] = 0
    end

    respond_to do |format|
      format.html
      format.pdf { render :template => "schedule/custom_pdf" }
    end
  end

  def events
    @events = @conference.events.public.accepted.scheduled.order(:title)
  end

  def event
    @event = @conference.events.public.accepted.scheduled.find(params[:id])
  end

  def speakers
    @speakers = Person.publicly_speaking_at(@conference).order(:last_name, :first_name)
  end

  def speaker
    @speaker = Person.publicly_speaking_at(@conference).find(params[:id])
  end

end

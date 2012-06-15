class Public::ScheduleController < ApplicationController

  layout 'public_schedule'

  def index
    @days = @conference.days

    respond_to do |format|
      format.html
      format.xml
      format.xcal
      format.ics
      format.json { render :file => "public/schedule/index.json.erb", :content_type => 'application/json' }
    end
  end

  def style
  end

  def day
    @day = Date.parse(params[:date])
    @day_index = @conference.days.index(@day) + 1
    @all_rooms = @conference.rooms.public.all
    @rooms = Array.new
    @events = Hash.new
    @skip_row = Hash.new
    @all_rooms.each do |room|
      events = room.events.accepted.public.scheduled_on(@day).order(:start_time).all
      unless events.empty?
        @events[room] = events 
        @skip_row[room] = 0
        @rooms << room
      end
    end

    respond_to do |format|
      format.html
      format.pdf do
        @page_size = "A4"
        render :template => "schedule/custom_pdf" 
      end
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

class Public::ScheduleController < ApplicationController

  layout 'public_schedule'
  before_filter :maybe_authenticate_user!

  def index
    @days = @conference.days

    respond_to do |format|
      format.html
      format.xml
      format.xcal
      format.ics
      format.json { render file: "public/schedule/index.json.erb", content_type: 'application/json' }
    end
  end

  def style
  end

  def day
    @day_index = params[:day].to_i ||= 0
    @day = @conference.days[@day_index]
    @all_rooms = @conference.rooms.public.all
    @rooms = Array.new
    @events = Hash.new
    @skip_row = Hash.new
    @all_rooms.each do |room|
      events = room.events.confirmed.public.scheduled_on(@day).order(:start_time).all
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
        render template: "schedule/custom_pdf" 
      end
    end
  end

  def events
    @events = @conference.events.public.confirmed.scheduled.sort {|a,b|
      a.to_sortable <=> b.to_sortable
    }
  end

  def event
    @event = @conference.events.public.confirmed.scheduled.find(params[:id])
  end

  def speakers
    @speakers = Person.publicly_speaking_at(@conference).confirmed(@conference).order(:public_name, :first_name, :last_name)
  end

  def speaker
    @speaker = Person.publicly_speaking_at(@conference).confirmed(@conference).find(params[:id])
  end

  private

  def maybe_authenticate_user!
    authenticate_user! unless @conference.schedule_public
  end

end

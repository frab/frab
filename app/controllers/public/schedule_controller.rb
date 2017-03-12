class Public::ScheduleController < ApplicationController
  layout 'public_schedule'
  before_action :maybe_authenticate_user!

  def index
    @days = @conference.days

    respond_to do |format|
      format.html
      format.xml
      format.xcal
      format.ics
      format.json
    end
  end

  def style
    respond_to do |format|
      format.css
    end
  end

  def day
    @day_index = params[:day].to_i
    if @day_index < 1 || @day_index > @conference.days.count
      return redirect_to public_schedule_index_path, alert: "Failed to find day at index #{@day_index}"
    end

    setup_day_ivars

    if @rooms.empty?
      return redirect_to public_schedule_index_path, notice: 'No events are public and scheduled.'
    end

    respond_to do |format|
      format.html
      format.pdf do
        @layout = CustomPDF::FullPageLayout.new('A4')
        render template: 'schedule/custom_pdf'
      end
    end
  end

  def events
    @events = @conference.events_including_subs.is_public.confirmed.scheduled.sort { |a, b|
      a.to_sortable <=> b.to_sortable
    }
    @events_by_track = @events.group_by(&:track_id)
    respond_to do |format|
      format.html
      format.json
      format.xls { render file: 'public/schedule/events.xls.erb', content_type: 'application/xls' }
    end
  end

  def event
    @event = @conference.events_including_subs.is_public.confirmed.scheduled.find(params[:id])
    @concurrent_events = @conference.events_including_subs.is_public.confirmed.scheduled.where(start_time: @event.start_time)
    respond_to do |format|
      format.html
      format.ics
    end
  end

  def speakers
    @speakers = Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).order(:public_name, :first_name, :last_name)
    respond_to do |format|
      format.html
      format.json
      format.xls { render file: 'public/schedule/speakers.xls.erb', content_type: 'application/xls' }
    end
  end

  def speaker
    @speaker = Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).find(params[:id])
  end

  def qrcode
    @qr = RQRCode::QRCode.new(public_schedule_index_url(format: :xml), size: 8, level: :h)
  end

  private

  def maybe_authenticate_user!
    authenticate_user! unless @conference.schedule_public
  end

  def setup_day_ivars
    @day = @conference.days[@day_index - 1]
    all_rooms = @conference.rooms_including_subs
    @rooms = []
    @events = {}
    @skip_row = {}
    all_rooms.each do |room|
      events = room.events.confirmed.no_conflicts.is_public.scheduled_on(@day).order(:start_time).to_a
      next if events.empty?
      @events[room] = events
      @skip_row[room] = 0
      @rooms << room
    end
  end
end

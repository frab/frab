class ScheduleController < BaseConferenceController
  before_action :crew_only!, except: %i[update_track update_event]

  def index
    params[:day] ||= 0
    @schedules_events = []
    @day = @conference.days[params[:day].to_i]

    @scheduled_events = @conference.events.accepted.includes([:track, :room, :conflicts]).scheduled_on(@day).order(:title) unless @day.nil?
    @unscheduled_events = @conference.events.accepted.includes([:track, :room, :conflicts]).unscheduled.order(:title)
  end

  def update_track
    authorize @conference, :manage?
    @unscheduled_events = if params[:track_id] and params[:track_id] =~ /\d+/
                            @conference.events.accepted.unscheduled.where(track_id: params[:track_id])
                          else
                            @conference.events.accepted.unscheduled
                          end
    render partial: 'unscheduled_events'
  end

  def update_event
    authorize @conference, :manage?
    event = @conference.events.find(params[:id])
    affected_event_ids = event.update_attributes_and_return_affected_ids(event_params)
    @affected_events = @conference.events.find(affected_event_ids)
  end

  def new_pdf
    @orientations = %w[auto landscape portrait]
  end

  def custom_pdf
    return redirect_to :new_schedule_pdf unless params.key?(:room_ids)

    @page_size = params[:page_size]

    @day = @conference.days.find(params[:date_id])
    rooms = @conference.rooms.find(params[:room_ids])
    @view_model = ScheduleViewModel.new(@conference).for_day(@day)
    @view_model.select_rooms(rooms)

    @layout = page_layout(params[:page_size], params[:half_page])
    @rooms_per_page = params[:rooms_per_page].to_i
    @rooms_per_page = 1 if @rooms_per_page.zero?
    @events = filter_events_by_day_and_rooms(@day, rooms)

    @orientation = case params[:orientation]
                   when 'landscape'
                     :landscape
                   when 'portrait'
                     :portrait
                   else
                      rooms.size > 3 ? :landscape : :portrait
                   end

    respond_to do |format|
      format.pdf
    end
  rescue ActiveRecord::RecordNotFound => e
    flash[:notice] = e.message
    redirect_to action: :new_pdf
  end

  def html_exports
  end

  def create_static_export
    StaticProgramExportJob.new.async.perform @conference, check_conference_locale(params[:export_locale])
    redirect_to schedule_html_exports_path, notice: 'Static schedule export started. Please reload this page after a minute.'
  end

  def download_static_export
    conference_export = @conference.conference_export(check_conference_locale(params[:export_locale]))
    if conference_export&.tarball && File.readable?(conference_export.tarball.path)
      send_file conference_export.tarball.path, type: 'application/x-tar-gz'
    else
      redirect_to schedule_path, notice: 'No export found to download.'
    end
  end

  private

  def event_params
    params.require(:event).permit(:start_time, :room_id)
  end

  def check_conference_locale(locale = 'en')
    if @conference.language_codes.include?(locale)
      locale
    else
      @conference.language_codes.first
    end
  end

  def page_layout(page_size, half_page)
    if half_page
      CustomPDF::HalfPageLayout.new(page_size)
    else
      CustomPDF::FullPageLayout.new(page_size)
    end
  end

  def filter_events_by_day_and_rooms(day, rooms)
    events = {}
    rooms.each do |room|
      events[room] = room.events.accepted.is_public.scheduled_on(day).order(:start_time)
    end
    events
  end
end

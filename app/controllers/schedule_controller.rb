class ScheduleController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

  def index
    authorize! :read, Event
    params[:day] ||= 0
    @schedules_events = []
    @day = @conference.days[params[:day].to_i]

    @scheduled_events = @conference.events.accepted.includes([:track, :room,:conflicts]).scheduled_on(@day).order(:title) if not @day.nil?
    @unscheduled_events = @conference.events.accepted.includes([:track, :room,:conflicts]).unscheduled.order(:title)
  end

  def update_track
    authorize! :crud, Event
    if params[:track_id] and params[:track_id] =~ /\d+/
      @unscheduled_events = @conference.events.accepted.unscheduled.where(track_id: params[:track_id])
    else
      @unscheduled_events = @conference.events.accepted.unscheduled
    end
    render partial: "unscheduled_events"
  end

  def update_event
    authorize! :crud, Event
    event = @conference.events.find(params[:id])
    affected_event_ids = event.update_attributes_and_return_affected_ids(event_params)
    @affected_events = @conference.events.find(affected_event_ids)
  end

  def new_pdf
    authorize! :read, Event
  end

  def custom_pdf
    authorize! :read, Event
    @page_size = params[:page_size]
    @day = @conference.days.find(params[:date_id])
    @rooms = @conference.rooms.public.find(params[:room_ids])
    @events = Hash.new
    @rooms.each do |room|
      @events[room] = room.events.accepted.is_public.scheduled_on(@day).order(:start_time).all
    end

    respond_to do |format|
      format.pdf
    end
  end

  def html_exports
    authorize! :read, @conference
  end

  def create_static_export
    authorize! :read, @conference

    StaticProgramExportJob.new.async.perform @conference, check_conference_locale(params[:export_locale])
    redirect_to schedule_html_exports_path, notice: 'Static schedule export started. Please reload this page after a minute.'
  end

  def download_static_export
    authorize! :read, @conference

    conference_export = @conference.conference_export(check_conference_locale(params[:export_locale]))
    if conference_export.present? and File.readable? conference_export.tarball.path
      send_file conference_export.tarball.path, type: "application/x-tar-gz"
    else
      redirect_to schedule_path, notice: 'No export found to download.'
    end
  end

  private

  def event_params
    params.require(:event).permit(:start_time, :room_id)
  end

  def check_conference_locale(locale='en')
    if @conference.language_codes.include?(locale)
      locale
    elsif @conference.language_codes.present?
      @conference.language_codes.first
    else
      'en'
    end
  end

end

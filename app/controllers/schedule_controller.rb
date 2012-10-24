class ScheduleController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :event, :parent => false

  def index
    params[:day] ||= 0
    @schedules_events = []
    @day = @conference.days[params[:day].to_i]

    @scheduled_events = @conference.events.accepted.scheduled_on(@day).order(:title) if not @day.nil?
    @unscheduled_events = @conference.events.accepted.unscheduled.order(:title)
  end

  def update_track
    if params[:track_id] and params[:track_id] =~ /\d+/
      @unscheduled_events = @conference.events.accepted.unscheduled.where(:track_id => params[:track_id])
    else
      @unscheduled_events = @conference.events.accepted.unscheduled
    end
    render :partial => "unscheduled_events"
  end

  def update_event
    event = @conference.events.find(params[:id])
    affected_event_ids = event.update_attributes_and_return_affected_ids(params[:event])
    @affected_events = @conference.events.find(affected_event_ids)
  end

  def new_pdf
  end

  def custom_pdf
    @page_size = params[:page_size]
    @day = @conference.days.find(params[:date_id])
    @rooms = @conference.rooms.public.find(params[:room_ids])
    @events = Hash.new
    @rooms.each do |room|
      @events[room] = room.events.accepted.public.scheduled_on(@day).order(:start_time).all
    end

    respond_to do |format|
      format.pdf
    end
  end

end

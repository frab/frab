class ScheduleController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin

  def index
    params[:day] ||= 0
    @day = @conference.days[params[:day].to_i]
    @scheduled_events = @conference.events.scheduled_on(@day)
    @unscheduled_events = @conference.events.accepted.unscheduled
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

end

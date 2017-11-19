class Cfp::ScheduleController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!
  before_action :check_schedule_open!

  def index
    params[:day] ||= 0
    @schedules_events = []
    @day = @conference.days[params[:day].to_i]

    @scheduled_events = @conference.events.accepted.includes([:track, :room, :conflicts]).scheduled_on(@day).order(:title) unless @day.nil?
    @unscheduled_events = @conference.events.accepted.includes([:track, :room, :conflicts]).unscheduled.order(:title)
  end

  def update_event
    event = @conference.events.find(params[:id])
    affected_event_ids = event.update_attributes_and_return_affected_ids(event_params)
    @affected_events = @conference.events.find(affected_event_ids)
  end

  private

  def check_schedule_open!
    return redirect_to cfp_person_path unless @conference.schedule_open?
  end

  def event_params
    params.require(:event).permit(:start_time, :room_id)
  end
end

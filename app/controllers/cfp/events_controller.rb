class Cfp::EventsController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!, except: :confirm

  # GET /cfp/events
  # GET /cfp/events.xml
  def index
    authorize! :submit, Event

    @events = current_user.person.events
    @events&.map(&:clean_event_attributes!)

    respond_to do |format|
      format.html { redirect_to cfp_person_path }
      format.xml  { render xml: @events }
    end
  end

  # GET /cfp/events/1
  def show
    authorize! :submit, Event
    redirect_to(edit_cfp_event_path)
  end

  # GET /cfp/events/new
  def new
    authorize! :submit, Event
    @event = Event.new(time_slots: @conference.default_timeslots)
    @event.recording_license = @conference.default_recording_license

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /cfp/events/1/edit
  def edit
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id])
  end

  # POST /cfp/events
  def create
    authorize! :submit, Event
    @event = Event.new(event_params.merge(recording_license: @conference.default_recording_license))
    @event.conference = @conference
    @event.event_people << EventPerson.new(person: current_user.person, event_role: 'submitter')
    @event.event_people << EventPerson.new(person: current_user.person, event_role: 'speaker')

    respond_to do |format|
      if @event.save
        format.html { redirect_to(cfp_person_path, notice: t('cfp.event_created_notice')) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /cfp/events/1
  def update
    authorize! :submit, Event
    @event = current_user.person.events.readonly(false).find(params[:id])
    @event.recording_license = @event.conference.default_recording_license unless @event.recording_license

    respond_to do |format|
      if @event.update_attributes(event_params)
        format.html { redirect_to(cfp_person_path, notice: t('cfp.event_updated_notice')) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def withdraw
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id], readonly: false)
    @event.withdraw!
    redirect_to(cfp_person_path, notice: t('cfp.event_withdrawn_notice'))
  end

  def confirm
    event_people = event_people_from_params
    if event_people.blank?
      return redirect_to cfp_person_path, flash: { error: t('cfp.no_confirmation_token') }
    end
    event_people.each(&:confirm!)

    if current_user
      redirect_to cfp_person_path, notice: t('cfp.thanks_for_confirmation')
    else
      redirect_to new_user_session_path
    end
  end

  private

  def event_people_from_params
    if params[:token]
      event_person = EventPerson.find_by(confirmation_token: params[:token])
      return if event_person.nil?
      event_person.person.event_people.where(event_id: params[:id])

    elsif current_user
      current_user.person.event_people.where(event_id: params[:id])
    end
  end

  def event_params
    params.require(:event).permit(
      :title, :subtitle, :event_type, :time_slots, :language, :abstract, :description, :logo, :track_id, :submission_note, :tech_rider,
      event_attachments_attributes: %i(id title attachment public _destroy),
      links_attributes: %i(id title url _destroy)
    )
  end
end

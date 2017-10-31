class Cfp::EventsController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!, except: :confirm

  # GET /cfp/events
  def index
    @events = current_user.person.events
    @events&.map(&:clean_event_attributes!)

    respond_to do |format|
      format.html { redirect_to cfp_person_path }
    end
  end

  # GET /cfp/events/1
  def show
    redirect_to(edit_cfp_event_path)
  end

  # GET /cfp/events/new
  def new
    @event = Event.new(time_slots: @conference.default_timeslots)
    @event.recording_license = @conference.default_recording_license

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /cfp/events/1/edit
  def edit
    @event = current_user.person.events.find(params[:id])
  end

  # POST /cfp/events
  def create
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

  def join
    @token = params[:token] || ''
    @event = @token.blank? ? nil : Event.find_by(invite_token: @token)

    deadline = @event&.conference&.call_for_participation&.hard_deadline
    if deadline && Date.today > deadline
      return redirect_to cfp_root_path, flash: { error: t('cfp.hard_deadline_over') }
    end

    return unless request.post?

    if @event.nil?
        return redirect_to cfp_join_event_path, flash: { error: t('cfp.join_token_unknown', token: @token) }
    end
    if @event.people.exists?(current_user.person.id)
        redirect_to edit_cfp_event_path(@event), notice: t('cfp.join_token_already_used')
    else
        @event.event_people << EventPerson.new(person: current_user.person, event_role: 'speaker')
        redirect_to edit_cfp_event_path(@event), notice: t('cfp.join_success')
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
      event_classifiers_attributes: %i(id classifier_id value _destroy),
      links_attributes: %i(id title url _destroy)
    )
  end
end

class Cfp::EventsController < ApplicationController

  layout "cfp"

  before_filter :authenticate_user!, :except => :confirm

  # GET /cfp/events
  # GET /cfp/events.xml
  def index
    authorize! :submit, Event
    @events = current_user.person.events.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /cfp/events/1
  # GET /cfp/events/1.xml
  def show
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /cfp/events/new
  # GET /cfp/events/new.xml
  def new
    authorize! :submit, Event
    @event = Event.new(:time_slots => @conference.default_timeslots)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /cfp/events/1/edit
  def edit
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id])
  end

  # POST /cfp/events
  # POST /cfp/events.xml
  def create
    authorize! :submit, Event
    @event = Event.new(params[:event])
    @event.conference = @conference
    @event.event_people << EventPerson.new(:person => current_user.person, :event_role => "submitter")
    @event.event_people << EventPerson.new(:person => current_user.person, :event_role => "speaker")

    respond_to do |format|
      if @event.save
        format.html { redirect_to(cfp_person_path, :notice => t("cfp.event_created_notice")) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cfp/events/1
  # PUT /cfp/events/1.xml
  def update
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id], :readonly => false)

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(cfp_person_path, :notice => t("cfp.event_updated_notice")) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def withdraw
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id], :readonly => false)
    @event.withdraw!
    redirect_to(cfp_person_path, :notice => t("cfp.event_withdrawn_notice"))
  end

  def confirm
    if params[:token]
      event_person = EventPerson.find_by_confirmation_token(params[:token])
      event_people = event_person.person.event_people.find_all_by_event_id(params[:id])
      login_as(event_person.person.user) if event_person.person.user
    else
      raise "Unauthenticated" unless current_user
      event_people = current_user.person.event_people.find_all_by_event_id(params[:id])
    end
    event_people.each do |event_person|
      event_person.confirm!
    end
    if current_user
      redirect_to cfp_person_path, :notice => t("cfp.thanks_for_confirmation")
    else
      render :layout => "signup"
    end
  end

end

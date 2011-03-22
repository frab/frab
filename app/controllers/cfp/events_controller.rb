class Cfp::EventsController < ApplicationController

  layout "cfp"

  before_filter :authenticate_cfp_user!
  before_filter :require_submitter

  # GET /cfp/events
  # GET /cfp/events.xml
  def index
    @events = current_cfp_user.person.events.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /cfp/events/1
  # GET /cfp/events/1.xml
  def show
    @event = current_cfp_user.person.events.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /cfp/events/new
  # GET /cfp/events/new.xml
  def new
    @event = Event.new(:time_slots => @conference.default_timeslots)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /cfp/events/1/edit
  def edit
    @event = current_cfp_user.person.events.find(params[:id])
  end

  # POST /cfp/events
  # POST /cfp/events.xml
  def create
    @event = Event.new(params[:event])
    @event.conference = @conference
    @event.event_people << EventPerson.new(:person => current_cfp_user.person, :event_role => "submitter")
    @event.event_people << EventPerson.new(:person => current_cfp_user.person, :event_role => "speaker")

    respond_to do |format|
      if @event.save
        format.html { redirect_to(cfp_person_path, :notice => 'Event was successfully created.') }
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
    @event = current_cfp_user.person.events.find(params[:id], :readonly => false)

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(cfp_person_path, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def withdraw
    @event = current_cfp_user.person.events.find(params[:id], :readonly => false)
    @event.withdraw!
    redirect_to(cfp_person_path, :notice => "Your submission has been withdrawn.")
  end

end

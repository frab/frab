class EventsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin
  
  # GET /events
  # GET /events.xml
  def index
    if params[:term]
      @search = @conference.events.with_query(params[:term]).search(params[:q])
      @events = @search.result.paginate :page => params[:page]
    else
      @search = @conference.events.search(params[:q])
      @events = @search.result.paginate :page => params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  def my
    if params[:term]
      @search = @conference.events.associated_with(current_user.person).with_query(params[:term]).search(params[:q])
      @events = @search.result.paginate :page => params[:page]
    else
      @search = @conference.events.associated_with(current_user.person).search(params[:q])
      @events = @search.result.paginate :page => params[:page]
    end
  end

  def cards
    if params[:accepted]
      @events = @conference.events.accepted
    else
      @events = @conference.events
    end
    
    respond_to do |format|
      format.pdf
    end
  end

  def ratings
    @search = @conference.events.search(params[:q])
    @events = @search.result.paginate :page => params[:page]
    @events_total = @conference.events.count
    @events_no_review_total = @events_total - @conference.events.joins(:event_ratings).count
    @events_reviewed = @conference.events.joins(:event_ratings).where("event_ratings.person_id" => current_user.person.id).count
    @events_no_review = @events_total - @conference.events.joins(:event_ratings).count
  end

  def start_review
    ids = Event.ids_by_least_reviewed(@conference, current_user.person)
    if ids.empty?
      redirect_to :action => "ratings", :notice => "You have already reviewed all events:"
    else
      session[:review_ids] = ids
      redirect_to event_event_rating_path(:event_id => ids.first)
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def people
    @event = Event.find(params[:id])
  end
  
  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  def edit_people
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.conference = @conference

    respond_to do |format|
      if @event.save
        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
        format.js   { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_state
    @event = Event.find(params[:id])
    if params[:send_mail]
      redirect_to(@event, :alert => "Cannot send mails: Please specify an email address for this conference.") and return unless @conference.email
      redirect_to(@event, :alert => "Cannot send mails: Not all speakers have email addresses.") and return unless @event.speakers.all?{|s| s.email}
    end
    @event.send(:"#{params[:transition]}!", :send_mail => params[:send_mail], :coordinator => current_user.person)
    redirect_to @event, :notice => 'Event was successfully updated.' 
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
end

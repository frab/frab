class EventsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!
  after_filter :restrict_events
  
  # GET /events
  # GET /events.xml
  def index
    authorize! :read, Event
    if params.has_key?(:term) and not params[:term].empty?
      @search = @conference.events.with_query(params[:term]).includes(:track).search(params[:q])
    else
      @search = @conference.events.includes(:track).search(params[:q])
    end
    @events = @search.result.paginate page: params[:page]

    clean_events_attributes
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @events }
    end
  end

  # current_users events
  def my
    authorize! :read, Event
    if params.has_key?(:term) and not params[:term].empty?
      @search = @conference.events.associated_with(current_user.person).with_query(params[:term]).search(params[:q])
    else
      @search = @conference.events.associated_with(current_user.person).search(params[:q])
    end
    clean_events_attributes
    @events = @search.result.paginate page: params[:page]
  end

  # events as pdf
  def cards
    authorize! :crud, Event
    if params[:accepted]
      @events = @conference.events.accepted
    else
      @events = @conference.events
    end
    
    respond_to do |format|
      format.pdf
    end
  end

  # show event ratings
  def ratings
    authorize! :create, EventRating
    @search = @conference.events.search(params[:q])
    @events = @search.result.paginate page: params[:page]
    clean_events_attributes

    # total ratings:
    @events_total = @conference.events.count
    @events_reviewed_total = @conference.events.select{|e| e.event_ratings_count != nil and e.event_ratings_count > 0 }.count
    @events_no_review_total = @events_total - @events_reviewed_total

    # current_user rated:
    @events_reviewed = @conference.events.joins(:event_ratings).where("event_ratings.person_id" => current_user.person.id).count
    @events_no_review = @events_total - @events_reviewed
  end

  # show event feedbacks
  def feedbacks
    authorize! :access, :event_feedback
    @search = @conference.events.accepted.search(params[:q])
    @events = @search.result.paginate page: params[:page]
  end

  # start batch event review
  def start_review
    authorize! :create, EventRating
    ids = Event.ids_by_least_reviewed(@conference, current_user.person)
    if ids.empty?
      redirect_to action: "ratings", notice: "You have already reviewed all events:"
    else
      session[:review_ids] = ids
      redirect_to event_event_rating_path(event_id: ids.first)
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    authorize! :read, @event

    clean_events_attributes
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @event }
    end
  end

  # people tab of event detail page, the rating and
  # feedback tabs are handled in routes.rb
  # GET /events/2/people
  def people
    @event = Event.find(params[:id])
    authorize! :read, @event
  end
  
  # GET /events/new
  # GET /events/new.xml
  def new
    authorize! :crud, Event
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    authorize! :edit, @event
  end

  # GET /events/2/edit_people
  def edit_people
    @event = Event.find(params[:id])
    authorize! :manage, @event
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.conference = @conference
    authorize! :create, @event

    respond_to do |format|
      if @event.save
        format.html { redirect_to(@event, notice: 'Event was successfully created.') }
        format.xml  { render xml: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    authorize! :update, @event

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, notice: 'Event was successfully updated.') }
        format.xml  { head :ok }
        format.js   { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # update event state
  # GET /events/2/update_state?transition=cancel
  def update_state
    @event = Event.find(params[:id])
    authorize! :update, @event

    if params[:send_mail]

      # If integrated mailing is used, take care that a notification text is present.
      if @event.conference.call_for_papers.notifications.empty?
        return redirect_to edit_call_for_papers_path, alert: 'No notification text present. Please change the default text for your needs, before accepting/ rejecting events.'
      end

      return redirect_to(@event, alert: "Cannot send mails: Please specify an email address for this conference.") unless @conference.email

      return redirect_to(@event, alert: "Cannot send mails: Not all speakers have email addresses.") unless @event.speakers.all?{|s| s.email}
    end

    begin
      @event.send(:"#{params[:transition]}!", send_mail: params[:send_mail], coordinator: current_user.person)
    rescue => ex
      return redirect_to(@event, alert: "Cannot send mails: #{ex}.")
    end

    redirect_to @event, notice: 'Event was successfully updated.' 
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    authorize! :destroy, @event
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  private

  def restrict_events
    unless @events.nil?
      @events = @events.accessible_by(current_ability)
    end
  end

  def clean_events_attributes
    return if can? :crud, Event
    unless @event.nil?
      @event.clean_event_attributes!
    end
    unless @events.nil?
      @events.map { |event| event.clean_event_attributes! } 
    end
  end

end

class PeopleController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :person, :parent => false

  # GET /people
  # GET /people.xml
  def index
    if params[:term]
      @people = Person.involved_in(@conference).with_query(params[:term]).paginate :page => params[:page]
    else
      @people = Person.involved_in(@conference).paginate :page => params[:page]
    end
  end

  def speakers
    respond_to do |format|
      format.html do
        if params[:term]
          @people = Person.speaking_at(@conference).with_query(params[:term]).paginate :page => params[:page]
        else
          @people = Person.speaking_at(@conference).paginate :page => params[:page]
        end
      end
      format.text do
        @people = Person.speaking_at(@conference)
        render :text => @people.map(&:email).join("\n")
      end
    end
  end

  def all
    if params[:term]
      @people = Person.with_query(params[:term]).paginate :page => params[:page]
    else
      @people = Person.paginate :page => params[:page]
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    @current_events = @person.events.where(:conference_id => @conference.id).all
    @other_events = @person.events.where(Event.arel_table[:conference_id].not_eq(@conference.id)).all
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end
end

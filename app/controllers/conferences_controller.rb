class ConferencesController < ApplicationController

  skip_before_filter :load_conference, :only => :new

  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /conferences
  # GET /conferences.xml
  def index
    @conferences = Conference.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /conferences/1
  # GET /conferences/1.xml
  def show
    @conference = Conference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /conferences/new
  # GET /conferences/new.xml
  def new
    params.delete(:conference_acronym)
    @conference = Conference.new
    @first = true if Conference.count == 0

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /conferences/1/edit
  def edit
  end

  # POST /conferences
  # POST /conferences.xml
  def create
    @conference = Conference.new(params[:conference])

    respond_to do |format|
      if @conference.save
        format.html { redirect_to(conference_home_path(:conference_acronym => @conference.acronym), :notice => 'Conference was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /conferences/1
  # PUT /conferences/1.xml
  def update
    respond_to do |format|
      if @conference.update_attributes(params[:conference])
        format.html { redirect_to(edit_conference_path(:conference_acronym => @conference.acronym), :notice => 'Conference was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /conferences/1
  # DELETE /conferences/1.xml
  def destroy
    @conference = Conference.find(params[:id])
    @conference.destroy

    respond_to do |format|
      format.html { redirect_to(conferences_url) }
      format.xml  { head :ok }
    end
  end
end

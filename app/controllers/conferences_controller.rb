class ConferencesController < ApplicationController

  # these methods don't need a conference
  skip_before_filter :load_conference, only: [:new, :index, :create]

  before_filter :authenticate_user!
  before_filter :not_submitter!
  load_and_authorize_resource

  # GET /conferences
  # GET /conferences.xml
  def index
    if params.has_key?(:term) and not params[:term].empty?
      @search = Conference.with_query(params[:term]).search(params[:q])
    else
      @search = Conference.search(params[:q])
    end
    @conferences = @search.result.paginate page: params[:page]

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
        format.html { redirect_to(conference_home_path(conference_acronym: @conference.acronym), notice: 'Conference was successfully created.') }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /conferences/1
  # PUT /conferences/1.xml
  def update
    respond_to do |format|
      if @conference.update_attributes(params[:conference])
        format.html { redirect_to(edit_conference_path(conference_acronym: @conference.acronym), notice: 'Conference was successfully updated.') }
      else
        # redirect to the right nested form page
        format.html { render action: get_previous_nested_form(params[:conference]) }
      end
    end
  end

  # DELETE /conferences/1
  # DELETE /conferences/1.xml
  def destroy
    @conference.destroy

    respond_to do |format|
      format.html { redirect_to(conferences_path) }
      format.xml  { head :ok }
    end
  end

  private

  def get_previous_nested_form(parameters)
    parameters.keys.each { |name|
      attribs = name.index("_attributes") 
      next if attribs.nil?
      next unless attribs > 0
      test = name.gsub("_attributes", '')
      next unless %w{rooms days schedule tracks ticket_server }.include?(test)
      return "edit_#{test}"
    }
    return "edit"
  end

end

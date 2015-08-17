class PeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  after_action :restrict_people

  # GET /people
  # GET /people.xml
  def index
    authorize! :administrate, Person
    result = search Person.involved_in(@conference), params
    @people = result.paginate page: page_param
  end

  def speakers
    authorize! :administrate, Person
    @people = Person.speaking_at(@conference).accessible_by(current_ability)

    respond_to do |format|
      format.html do
        result = search Person.involved_in(@conference), params
        @people = result.paginate page: page_param
      end
      format.text do
        render text: @people.map(&:email).join("\n")
      end
    end
  end

  def all
    authorize! :administrate, Person
    result = search Person, params
    @people = result.paginate page: page_param
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    authorize! :read, @person
    @current_events = @person.events_as_presenter_in(@conference)
    @other_events = @person.events_as_presenter_not_in(@conference)
    if cannot? :manage, Event
      @current_events.map(&:clean_event_attributes!)
      @other_events.map(&:clean_event_attributes!)
    end
    @availabilities = @person.availabilities.where("conference_id = #{@conference.id}")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @person }
    end
  end

  def feedbacks
    @person = Person.find(params[:id])
    authorize! :access, :event_feedback
    @current_events = @person.events_as_presenter_in(@conference)
    @other_events = @person.events_as_presenter_not_in(@conference)
  end

  def attend
    @person = Person.find(params[:id])
    @person.set_role_state(@conference, 'attending')
    redirect_to action: :show
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new
    authorize! :manage, @person

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    if @person.nil?
      flash[:alert] = "Not a valid person"
      return redirect_to action: :index
    end
    authorize! :manage, @person
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(person_params)
    authorize! :manage, @person

    respond_to do |format|
      if @person.save
        format.html { redirect_to(@person, notice: 'Person was successfully created.') }
        format.xml  { render xml: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])
    authorize! :manage, @person

    respond_to do |format|
      if @person.update_attributes(person_params)
        format.html { redirect_to(@person, notice: 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    authorize! :manage, @person
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end

  private

  def restrict_people
    @people = @people.accessible_by(current_ability) unless @people.nil?
  end

  def search(people, params)
    if params.key?(:term) and not params[:term].empty?
      term = params[:term]
      sort = params[:q][:s] rescue nil
      @search = people.ransack(first_name_cont: term,
                               last_name_cont: term,
                               public_name_cont: term,
                               email_cont: term,
                               abstract_cont: term,
                               description_cont: term,
                               user_email_cont: term,
                               m: 'or',
                               s: sort)
    else
      @search = people.ransack(params[:q])
    end

    @search.result(distinct: true)
  end

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, :note,
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy)
    )
  end
end

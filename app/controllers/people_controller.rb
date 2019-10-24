class PeopleController < BaseConferenceController
  before_action :manage_only!, except: %i[show]
  include Searchable

  # GET /people
  # GET /people.json
  def index
    @people = search Person.involved_in(@conference)

    respond_to do |format|
      format.html { @people = @people.paginate page: page_param }
      format.json
    end
  end

  def speakers
    respond_to do |format|
      format.html do
        result = search Person.involved_in(@conference)
        @people = result.paginate page: page_param
      end
      format.text do
        @people = Person.speaking_at(@conference)
        render text: @people.map(&:email).join("\n")
      end
    end
  end

  def all
    authorize Person, :manage?
    result = search Person
    @people = result.paginate page: page_param

    respond_to do |format|
      format.html
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = authorize Person.find(params[:id])
    @view_model = PersonViewModel.new(current_user, @person, @conference)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def feedbacks
    @person = Person.find(params[:id])
    authorize Conference, :index?
    @current_events = @person.events_as_presenter_in(@conference)
    @other_events = @person.events_as_presenter_not_in(@conference)
  end

  def attend
    @person = authorize Person.find(params[:id])
    @person.set_role_state(@conference, 'attending')
    redirect_to action: :show
  end

  # GET /people/new
  def new
    authorize Person
    @person = Person.new

    respond_to do |format|
      format.html
    end
  end

  # GET /people/1/edit
  def edit
    @person = authorize Person.find(params[:id])
  end

  # POST /people
  def create
    @person = authorize Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to(@person, notice: t('people_module.notice_person_created')) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /people/1
  def update
    @person = authorize Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(person_params)
        format.html { redirect_to(@person, notice: t('people_module.notice_person_updated')) }
      else
        flash_model_errors(@person)
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /people/1
  def destroy
    @person = authorize Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
    end
  end

  private

  def search(people)
    @search = perform_search(people, params,
      %i(first_name_cont last_name_cont public_name_cont email_cont
      abstract_cont description_cont user_email_cont))
    @search.result(distinct: true)
  end

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, :note,
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy),
      ticket_attributes: %i(id remote_ticket_id)
    )
  end
end

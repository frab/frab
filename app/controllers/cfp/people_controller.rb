class Cfp::PeopleController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!
  before_action :check_cfp_open

  def show
    @person = current_user.person
    return redirect_to action: 'new' unless @person

    if redirect_submitter_to_edit?
      flash[:alert] = t('users_module.error_invalid_public_name')
      return redirect_to action: 'edit'
    end

    if !@conference.in_the_past? && !@person.events_in(@conference).empty? && @person.availabilities_in(@conference).count.zero?
      flash.now[:alert] = t('cfp.specify_availability')
    end

    respond_to do |format|
      format.html
    end
  end

  def import
    @person = current_user.person

    respond_to do |format|
      foaf = ActionController::Parameters.new(JSON.parse(foaf_params))
      @person.avatar = StringIO.new(Base64.decode64(foaf['avatar'])) if foaf['avatar']
      if @person.update_attributes(person_foaf_params(foaf))
        format.html { redirect_to(cfp_person_path, notice: t('cfp.person_updated_notice')) }
      else
        format.html { render action: 'export' }
      end
    end
  end

  def export
    @person = current_user.person
    @foaf = Cfp::PeopleController.renderer.render(
        action: :export,
        formats: ['json'],
        locals: { conference: @conference, person: @person }
    )
  end

  # It is possbile to create a person object via XML, but not to view it.
  # That's because not all fields should be visible to the user.
  def new
    @person = Person.new(email: current_user.email)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @person }
    end
  end

  def edit
    @person = current_user.person
    if @person.nil?
      flash[:alert] = t('users_module.error_invalid_person')
      return redirect_to action: :index
    end
  end

  def create
    @person = current_user.person
    if @person.nil?
      @person = Person.new(person_params)
      @person.user = current_user
    end

    respond_to do |format|
      if @person.save
        format.html { redirect_to(cfp_person_path, notice: t('cfp.person_created_notice')) }
        format.xml  { render xml: @person, status: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @person = current_user.person

    respond_to do |format|
      if @person.update_attributes(person_params)
        format.html { redirect_to(cfp_person_path, notice: t('cfp.person_updated_notice')) }
        format.xml  { head :ok }
      else
        flash_model_errors(@person)
        format.html { render action: 'edit' }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings,
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy)
    )
  end

  def foaf_params
    params.require(:foaf)
  end

  def person_foaf_params(foaf)
    foaf.permit(:first_name, :public_name, :email, :email_public, :include_in_mailings, :gender, :abstract, :description)
  end
end

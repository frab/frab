class Cfp::AvailabilitiesController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!

  def new
    authorize! :create, current_user.person
    @availabilities = Availability.build_for(@conference)
  end

  def edit
    authorize! :edit, current_user.person
    @availabilities = current_user.person.availabilities_in(@conference)
  end

  def update
    authorize! :update, current_user.person
    if params.key? :person
      current_user.person.update_attributes_from_slider_form(person_params)
    end
    redirect_to cfp_root_path, notice: t('cfp.update_availability_notice')
  end

  private

  def person_params
    params.require(:person).permit(:first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, availabilities_attributes: %i(id start_date end_date conference_id day_id))
  end
end

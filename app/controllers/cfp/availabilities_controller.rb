class Cfp::AvailabilitiesController < ApplicationController
  before_action :authenticate_user!

  def new
    @availabilities = Availability.build_for(@conference)
  end

  def edit
    @availabilities = current_user.person.availabilities_in(@conference)
  end

  def update
    if params.key? :person
      current_user.person.update_from_slider_form(person_params)
    end
    redirect_to cfp_person_path, notice: t('cfp.update_availability_notice')
  end

  private

  def person_params
    params.require(:person).permit(:first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, availabilities_attributes: %i(id start_date end_date conference_id day_id))
  end
end

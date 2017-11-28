class AvailabilitiesController < BaseConferenceController
  before_action :find_person

  def new
    @availabilities = Availability.build_for(@conference)
    flash[:alert] = t('availabilities.error_person_unavailable', {person: @person.full_name})
  end

  def edit
    @availabilities = @person.availabilities_in(@conference)
  end

  def update
    @person.update_attributes_from_slider_form(person_params)
    redirect_to(person_url(@person), notice: t('availabilities.success_update'))
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
    authorize @conference, :manage?
  end

  def person_params
    params.require(:person).permit(:first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, availabilities_attributes: %i(id start_date end_date conference_id day_id))
  end
end

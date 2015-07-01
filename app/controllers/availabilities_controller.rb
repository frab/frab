class AvailabilitiesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!
  before_filter :find_person

  def new
    @availabilities = Availability.build_for(@conference)
    flash[:alert] = "#{@person.full_name} does not currently have any availabilities."
  end

  def edit
    @availabilities = @person.availabilities_in(@conference)
  end

  def update
    @person.update_attributes_from_slider_form(person_params)
    redirect_to(person_url(@person), notice: 'Availibility was successfully updated.')
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
    authorize! :create, @person
  end

  def person_params
    params.require(:person).permit(:first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar_file_name, :abstract, :description, :include_in_mailings, availabilities_attributes: %i(id start_date end_date conference_id day_id))
  end
end

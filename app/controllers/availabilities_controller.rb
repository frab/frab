class AvailabilitiesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :person, :parent => false
  before_filter :find_person

  def new
    @availabilities = Availability.build_for(@conference)
  end

  def edit
    @availabilities = @person.availabilities_in(@conference)
  end

  def update
    @person.update_attributes(params[:person])
    redirect_to(person_url(@person), :notice => 'Availibility was successfully updated.')
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
  end

end

class Cfp::AvailabilitiesController < ApplicationController

  layout 'cfp'

  before_filter :authenticate_user!

  def new
    can? :create, Person
    @availabilities = Availability.build_for(@conference)
  end

  def edit
    can? :edit, current_user.person
    @availabilities = current_user.person.availabilities_in(@conference)
  end

  def update
    can? :update, current_user.person
    current_user.person.update_attributes_from_slider_form(params[:person])
    redirect_to cfp_root_path, :notice => t("cfp.update_availability_notice") 
  end

end

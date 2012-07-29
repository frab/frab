class Cfp::AvailabilitiesController < ApplicationController

  layout 'cfp'

  before_filter :authenticate_user!
  #load_and_authorize_resource :person, :parent => false

  def new
    can? :create, Person
    @availabilities = Availability.build_for(@conference)
  end

  def edit
    can? :edit, Person
    @availabilities = current_user.person.availabilities_in(@conference)
  end

  def update
    can? :update, Person
    current_user.person.update_attributes(params[:person])
    redirect_to cfp_root_path, :notice => t("cfp.update_availability_notice") 
  end

end

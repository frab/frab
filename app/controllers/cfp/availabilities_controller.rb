class Cfp::AvailabilitiesController < ApplicationController

  layout 'cfp'

  before_filter :authenticate_user!

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
    if params.has_key? :person
      current_user.person.update_attributes_from_slider_form(params[:person])
    end
    redirect_to cfp_root_path, notice: t("cfp.update_availability_notice") 
  end

end

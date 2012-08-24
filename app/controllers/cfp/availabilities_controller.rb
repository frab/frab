class Cfp::AvailabilitiesController < FrabApplicationController

  layout 'cfp'

  before_filter :authenticate_user!
  before_filter :require_submitter

  def new
    @availabilities = Availability.build_for(@conference)
  end

  def edit
    @availabilities = current_user.person.availabilities_in(@conference)
  end

  def update
    current_user.person.update_attributes(params[:person])
    redirect_to cfp_root_path, :notice => t("cfp.update_availability_notice") 
  end

end

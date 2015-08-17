class Cfp::SessionsController < SessionsController
  layout 'signup'

  before_action :check_cfp_open

  protected

  def successful_sign_in_path
    cfp_person_path
  end
end

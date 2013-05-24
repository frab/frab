class Cfp::SessionsController < SessionsController

  layout 'signup'

  before_filter :check_cfp_open

  protected

  def successful_sign_in_path
    cfp_person_path
  end

end

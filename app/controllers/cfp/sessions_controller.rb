class Cfp::SessionsController < SessionsController

  before_filter :check_cfp_open

  protected

  def successful_sign_in_path
    cfp_person_path
  end

  def check_cfp_open
    redirect_to cfp_open_soon_path if @conference.call_for_papers.start_date > Date.today
  end

end

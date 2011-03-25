class Cfp::SessionsController < Devise::SessionsController

  layout 'signup'

  before_filter :check_cfp_open
  before_filter :check_pentabarf_credentials, :only => :create

  protected

  def check_cfp_open
    redirect_to cfp_open_soon_path if @conference.call_for_papers.start_date > Date.today
  end

  def check_pentabarf_credentials
    User.check_pentabarf_credentials(params[:cfp_user][:email], params[:cfp_user][:password])
  end

end

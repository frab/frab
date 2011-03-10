class Cfp::SessionsController < Devise::SessionsController

  layout 'signup'

  before_filter :check_pentabarf_credentials, :only => :create

  protected

  def check_pentabarf_credentials
    User.check_pentabarf_credentials(params[:cfp_user][:email], params[:cfp_user][:password])
  end

end

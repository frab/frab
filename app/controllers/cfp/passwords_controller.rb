class Cfp::PasswordsController < Devise::PasswordsController

  layout "signup"

  before_filter :set_call_for_papers, :only => :create

  private

  def set_call_for_papers
    user = User.find_by_email(params[:cfp_user][:email])
    if user
      user.update_attributes(:call_for_papers_id => @conference.call_for_papers.id)
    end
  end

end

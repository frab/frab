class Cfp::RegistrationsController < Devise::RegistrationsController

  layout "signup"

  before_filter :set_call_for_papers, :only => :create

  private

  def set_call_for_papers
    params[:cfp_user][:call_for_papers_id] = @conference.call_for_papers.id
  end

end

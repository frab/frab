class Cfp::WelcomeController < ApplicationController

  layout 'cfp'

  def open_soon
    redirect_to new_cfp_session_path unless @conference.call_for_papers.start_date > Date.today
  end

end

class Cfp::WelcomeController < ApplicationController

  layout 'cfp'

  def index
    if @conference.call_for_papers.start_date <= Date.today
      redirect_to cfp_person_path
    else
      render :action => "open_soon"
    end
  end

end

class Cfp::WelcomeController < ApplicationController
  layout 'cfp'

  def not_existing
    @user = User.new
    unless @conference.call_for_participation.nil?
      redirect_to new_cfp_session_path
    end
  end

  def open_soon
    @user = User.new
    unless @conference.call_for_participation.start_date > Date.today
      redirect_to new_cfp_session_path
    end
  end
end

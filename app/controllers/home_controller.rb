class HomeController < ApplicationController
  layout 'home'

  def index
    @past_conferences = Conference.past
    @future_conferences = Conference.future
  end

  def not_existing
    @user = User.new
    redirect_to new_cfp_session_path if @conference.call_for_participation
  end

  def open_soon
    @user = User.new
    redirect_to new_cfp_session_path if @conference.call_for_participation.start_date <= Date.today
  end
end

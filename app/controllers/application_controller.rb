class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_conference

  protected

  def load_conference
    @conference = Conference.find(params[:conference_id]) if params[:conference_id]
  end

end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_conference

  protected

  def load_conference
    if params[:conference_id]
      @conference = Conference.find(params[:conference_id])
    elsif Conference.count > 0
      @conference = Conference.last
    end
  end

  def default_url_options
    {:conference_acronym => @conference.acronym} if @conference
  end

end

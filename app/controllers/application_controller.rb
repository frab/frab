class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_conference

  protected

  def load_conference
    if params[:conference_acronym]
      @conference = Conference.find_by_acronym(params[:conference_acronym])
    elsif Conference.count > 0
      @conference = Conference.last
    end
    Time.zone = @conference.timezone if @conference
  end

  def default_url_options
    {:conference_acronym => @conference.acronym} if @conference
  end

end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  before_filter :load_conference

  protected

  def set_locale
    I18n.locale = params[:locale]
  end

  def load_conference
    if params[:conference_acronym]
      @conference = Conference.find_by_acronym(params[:conference_acronym])
    elsif Conference.count > 0
      @conference = Conference.current
      params[:conference_acronym] = @conference.acronym
    end
    Time.zone = @conference.timezone if @conference
  end

  def default_url_options
    result = {:locale => params[:locale]}
    if @conference
      result.merge!(:conference_acronym => @conference.acronym)
    end
    result
  end

  def current_user
    super || current_cfp_user
  end

  def require_admin
    require_role("admin", new_user_session_path)
  end

  def require_submitter
    require_role("submitter", new_cfp_user_session_path)
  end

  def require_role(role, redirect_path)
    user = current_user || current_cfp_user
    unless user and user.role == role 
      sign_out_all_scopes
      redirect_to redirect_path 
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User) && resource_or_scope.role == "submitter"
      cfp_root_path
    else
      super
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :cfp_user 
      new_cfp_user_session_path 
    else
      super
    end
  end

end

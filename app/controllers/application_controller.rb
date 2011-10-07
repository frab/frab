class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  prepend_before_filter :load_conference

  helper_method :current_user

  protected

  def set_locale
    I18n.locale = params[:locale]
  end

  def load_conference
    if params[:conference_acronym]
      @conference = Conference.find_by_acronym(params[:conference_acronym])
    elsif Conference.count > 0
      @conference = Conference.current
    end
    Time.zone = @conference.timezone if @conference
  end

  def info_for_paper_trail
    {:conference_id => @conference.id} if @conference
  end

  def default_url_options
    result = {:locale => params[:locale]}
    if @conference
      result.merge!(:conference_acronym => @conference.acronym)
    end
    result
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to scoped_sign_in_path unless current_user
  end

  def login_as(user)
    session[:user_id] = user.id
    @current_user = user
    user.record_login!
  end

  def require_admin
    require_role("admin", new_session_path)
  end

  def require_submitter
    require_role("submitter", new_cfp_session_path)
  end

  def require_role(role, redirect_path)
    user = current_user
    unless user and user.role == role 
      sign_out_all_scopes
      redirect_to redirect_path 
    end
  end

  def scoped_sign_in_path
    if request.path =~ /\/cfp/
      new_cfp_session_path
    else
      new_session_path
    end
  end

end

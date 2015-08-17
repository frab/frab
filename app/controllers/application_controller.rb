class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_locale
  prepend_before_filter :load_conference

  helper_method :current_user

  rescue_from CanCan::AccessDenied do |ex|
    Rails.logger.info "[ !!! ] Access Denied for #{current_user.email}/#{current_user.id}/#{current_user.role}: #{ex.message}"
    begin
      if current_user.is_submitter?
        redirect_to cfp_root_path, :notice => t(:"ability.denied")
      else
        redirect_to :back, :notice => t(:"ability.denied")
      end
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end
  end

  protected

  def page_param
    page = params[:page].to_i
    return page if page > 0
    1
  end

  def set_locale
    if %w(en de).include?(params[:locale])
      I18n.locale = params[:locale]
    else
      I18n.locale = 'en'
      params[:locale] = 'en'
    end
  end

  def load_conference
    if params[:conference_acronym]
      @conference = Conference.find_by_acronym(params[:conference_acronym])
      fail ActionController::RoutingError.new("Not found") unless @conference
    elsif session.key?(:conference_acronym)
      @conference = Conference.find_by_acronym(session[:conference_acronym])
    elsif Conference.count > 0
      @conference = Conference.current
    end

    session[:conference_acronym] = @conference.acronym unless @conference.nil?

    Time.zone = @conference.timezone if @conference
  end

  def info_for_paper_trail
    { conference_id: @conference.id } if @conference
  end

  def default_url_options
    result = { locale: params[:locale] }
    result.merge!(conference_acronym: @conference.acronym) if @conference
    result
  end

  def current_user
    user = nil
    # maybe the user got deleted, so lets wrap this in a rescue block
    begin
      user = User.find(session[:user_id]) if session[:user_id]
    rescue
    end
    @current_user ||= user
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, @conference)
  end

  def authenticate_user!
    redirect_to scoped_sign_in_path unless current_user
  end

  def not_submitter!
    return unless current_user
    redirect_to cfp_root_path, alert: "This action is not allowed" if current_user.is_submitter?
  end

  def login_as(user)
    session[:user_id] = user.id
    @current_user = user
    user.record_login!
  end

  def scoped_sign_in_path
    if request.path =~ /\/cfp/
      new_cfp_session_path
    else
      new_session_path
    end
  end

  def check_cfp_open
    if @conference.call_for_participation.nil?
      redirect_to cfp_not_existing_path
    elsif @conference.call_for_participation.start_date > Date.today
      redirect_to cfp_open_soon_path
    end
  end
end

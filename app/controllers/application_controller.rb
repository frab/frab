class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protect_from_forgery

  before_action :set_locale
  before_action :set_paper_trail_whodunnit
  prepend_before_action :load_conference

  rescue_from CanCan::AccessDenied do |ex|
    Rails.logger.info "[ !!! ] Access Denied for #{current_user.email}/#{current_user.id}/#{current_user.role}: #{ex.message}"
    begin
      if current_user.is_submitter?
        redirect_to cfp_person_path, notice: t(:"ability.denied")
      else
        redirect_to :back, notice: t(:"ability.denied")
      end
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end
  end

  protected

  def layout_by_resource
    if devise_controller?
      "home"
    else
      "application"
    end
  end

  def page_param
    page = params[:page].to_i
    return page if page.positive?
    1
  end

  def set_locale
    if %w(en de es pt-BR).include?(params[:locale])
      I18n.locale = params[:locale]
    else
      I18n.locale = 'en'
      params[:locale] = 'en'
    end
  end

  def load_conference
    @conference = conference_from_params
    @conference ||= conference_from_session

    session[:conference_acronym] = @conference&.acronym
    Time.zone = @conference&.timezone
  end

  def info_for_paper_trail
    return {} unless @conference
    { conference_id: @conference.id }
  end

  def default_url_options
    result = { locale: params[:locale] }
    result[:conference_acronym] = @conference.acronym if @conference
    result
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, @conference)
  end

  def not_submitter!
    redirect_to cfp_person_path, alert: 'This action is not allowed' if current_user&.is_submitter?
  end

  def check_cfp_open
    redirect_to cfp_root_path unless @conference.cfp_open?
  end

  private

  def conference_from_session
    return unless session.key?(:conference_acronym)
    Conference.includes(:parent).find_by(acronym: session[:conference_acronym])
  end

  def conference_from_params
    return unless params.key?(:conference_acronym)

    conference = Conference.includes(:parent).find_by(acronym: params[:conference_acronym])
    raise ActionController::RoutingError, 'Specified conference not found' unless conference
    conference
  end
end

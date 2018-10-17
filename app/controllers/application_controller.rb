class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery

  before_action :set_locale
  before_action :set_paper_trail_whodunnit
  prepend_before_action :load_conference

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def layout_if_conference
    return 'conference' if @conference && !@conference.new_record?
    'application'
  end

  def page_param
    page = params[:page].to_i
    return page if page.positive?
    1
  end

  def set_locale
    supported_languages = %w[en de es pt-BR fr zh ru it]

    if supported_languages.include?(params[:locale])
      I18n.locale = params[:locale]
    else
      preferred_language = http_accept_language.preferred_language_from(supported_languages) || 'en'

      I18n.locale     = preferred_language
      params[:locale] = preferred_language
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

  def not_submitter!
    redirect_to cfp_person_path, alert: 'This action is not allowed' if current_user&.is_submitter?
  end

  def orga_only!
    authorize @conference, :orga?
  end

  def manage_only!
    authorize @conference, :manage?
  end

  def crew_only!
    authorize @conference, :read?
  end

  def check_cfp_open
    redirect_to cfp_root_path unless @conference.cfp_open?
  end

  def redirect_submitter_to_edit?
    current_user.person.public_name == current_user.email
  end

  def flash_model_errors(model)
    flash[:errors] = model.errors.full_messages.join
  end

  private

  def user_not_authorized(ex)
    Rails.logger.info "[ !!! ] Access Denied for #{current_user.email}/#{current_user.id}/#{current_user.role}: #{ex.message}"
    begin
      if current_user.is_submitter?
        redirect_to cfp_person_path, notice: t(:"ability.denied")
      else
        redirect_back fallback_location: root_path, notice: t(:"ability.denied")
      end
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end
  end

  def conference_from_session
    return unless session.key?(:conference_acronym)
    Conference.includes(:parent).find_by(acronym: session[:conference_acronym])
  end

  def conference_from_params
    return unless params.key?(:conference_acronym)

    conference = Conference.includes(:parent).find_by(acronym: params[:conference_acronym])
    raise ActionController::RoutingError, t('conferences_module.error_specified_conference_not_found') unless conference
    conference
  end

  # maybe conference got deleted
  def deleted_conference_redirect_path
    return users_last_conference_path if current_user.last_conference
    new_conference_path
  end

  def users_last_conference_path
    conference_path(conference_acronym: current_user.last_conference.acronym)
  end

end

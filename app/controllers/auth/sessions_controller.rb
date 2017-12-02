class Auth::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  def after_sign_in_path_for(resource)
    return root_path unless session[:conference_acronym]
    if @conference && policy(@conference).manage?
      conference_path(conference_acronym: session[:conference_acronym])
    elsif redirect_submitter_to_edit?
      flash[:alert] = t('users_module.error_invalid_public_name')
      edit_cfp_person_path(conference_acronym: session[:conference_acronym])
    else
      cfp_person_path(conference_acronym: session[:conference_acronym])
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end

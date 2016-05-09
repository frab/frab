class Cfp::ConfirmationsController < ApplicationController
  layout 'signup'

  def new
    @user = User.new
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    @conference = Conference.find_by_acronym(params[:conference_acronym])

    # re-send
    if @user and @user.send_confirmation_instructions(@conference)
      redirect_to new_cfp_session_path, notice: t(:"cfp.confirmation_instructions_sent")
    else
      redirect_to new_cfp_user_confirmation_path, flash: { error: t(:"cfp.error_sending_confirmation_instructions") }
    end
  end

  def show
    @user = User.confirm_by_token(params[:confirmation_token])

    if @user
      login_as @user
      redirect_to cfp_person_path, notice: t('cfp.successfully_confirmed')
    else
      redirect_to new_cfp_user_confirmation_path, error: t('cfp.error_confirming')
    end
  end
end

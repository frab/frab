class Cfp::UsersController < ApplicationController
  layout 'cfp'
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    [:password, :password_confirmation].each do |password_key|
      params[:user].delete(password_key) if params[:user][password_key].blank?
    end

    if @user.update_attributes(user_params)
      bypass_sign_in(@user) if Devise.sign_in_after_reset_password
      redirect_to cfp_person_path, notice: t(:"cfp.updated")

    else
      flash_model_errors(@user)
      render action: 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

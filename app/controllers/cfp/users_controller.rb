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
      redirect_to cfp_person_path(@user.person), notice: t(:"cfp.updated")
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

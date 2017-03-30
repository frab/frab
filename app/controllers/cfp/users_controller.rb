class Cfp::UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    render layout: 'cfp'
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      redirect_to cfp_person_path, notice: t(:"cfp.updated")
    else
      render action: 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

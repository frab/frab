class SessionsController < ApplicationController
  layout 'team_signup'

  before_action :authenticate_user!, only: :destroy
  before_action :not_submitter!, except: :destroy
  before_action :check_user_params, only: :create
  before_action :check_pentabarf_credentials, only: :create

  def new
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = User.confirmed.find_by_email(user_params[:email])
    if @user and @user.authenticate(params[:user][:password])
      login_as @user
      redirect_to successful_sign_in_path, notice: t(:sign_in_successful)
    else
      @user = User.new
      flash[:alert] = t(:error_signing_in)
      render action: 'new'
    end
  end

  def destroy
    reset_session
    redirect_to scoped_sign_in_path
  end

  protected

  def successful_sign_in_path
    if current_user.is_submitter?
      cfp_person_path
    else
      if params.key?(:return_to)
        params[:return_to]
      else
        root_path
      end
    end
  end

  def check_pentabarf_credentials
    User.check_pentabarf_credentials(user_params[:email], user_params[:password])
  end

  def check_user_params
    if params.key?(:user)
      user = params[:user]
      return true if user.key?(:email) and user.key?(:password)
    end

    @user = User.new
    flash[:alert] = t(:error_signing_in)
    # abort processing
    render action: 'new'
  end

  private

  def user_params
    params.require(:user).permit(:password, :email, :remember_me)
  end
end

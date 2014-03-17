class SessionsController < ApplicationController

  layout 'team_signup'

  before_filter :authenticate_user!, only: :destroy
  before_filter :not_submitter!, except: :destroy
  before_filter :check_user_params, only: :create
  before_filter :check_pentabarf_credentials, only: :create

  def new
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = User.confirmed.find_by_email(params[:user][:email])
    if @user and @user.authenticate(params[:user][:password])
      login_as @user
      redirect_to successful_sign_in_path, notice: t(:sign_in_successful)
    else
      @user = User.new
      flash[:alert] = t(:error_signing_in) 
      render action: "new"
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
      root_path
    end
  end

  def check_pentabarf_credentials
    User.check_pentabarf_credentials(params[:user][:email], params[:user][:password])
  end

  def check_user_params
    if params.has_key?(:user)
      user = params[:user]
      return true if user.has_key?(:email) and user.has_key?(:password)
    end

    @user = User.new
    flash[:alert] = t(:error_signing_in) 
    # abort processing
    render action: "new"
  end

end

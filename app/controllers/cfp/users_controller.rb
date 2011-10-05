class Cfp::UsersController < ApplicationController

  layout 'signup'

  before_filter :authenticate_user!, :only => [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.call_for_papers = @conference.call_for_papers

    if @user.save
      redirect_to new_cfp_session_path, :notice => t(:"cfp.signed_up")
    else
      render :action => "new"
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.save
      redirect_to cfp_person_path, :notice => t(:"cfp.updated")
    else
      render :action => "new"
    end
  end

end

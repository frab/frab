class Cfp::UsersController < ApplicationController

  layout 'signup'

  before_filter :authenticate_user!, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.call_for_participation = @conference.call_for_participation
    @user.person = Person.new(email: @user.email, public_name: @user.email)

    if @user.save
      redirect_to new_cfp_session_path, notice: t(:"cfp.signed_up")
    else
      render action: "new"
    end
  end

  def edit
    @user = current_user
    render layout: "cfp"
  end

  def update
    @user = current_user
    if @user.save
      redirect_to cfp_person_path, notice: t(:"cfp.updated")
    else
      render action: "new"
    end
  end

end

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  before_action :find_person
  before_action :ensure_user, except: %i[new create]
  after_action :verify_authorized

  # GET /users/1
  # GET /users/1.xml
  def show
    authorize_manage_user
  end

  # GET /users/new
  def new
    authorize @conference, :orga?
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    authorize_manage_user
    @user.conference_users = policy_scope(@user.conference_users)
  end

  # POST /users
  def create
    authorize @conference, :manage?
    @user = User.new(user_params)

    set_allowed_user_roles(user_params[:role], 'submitter')
    @user.person = @person
    @user.skip_confirmation!

    respond_to do |format|
      if @user.save
        format.html { redirect_to(person_user_path(@person), notice: 'User was successfully created.') }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /users/1
  def update
    authorize_manage_user
    [:password, :password_confirmation].each do |password_key|
      params[:user].delete(password_key) if params[:user][password_key].blank?
    end

    set_allowed_user_roles(params[:user][:role])
    params[:user].delete(:role)

    # only allowed user.conference_users from selection
    if !current_user.is_admin? && policy(@conference).orga? && params[:user][:conference_users_attributes].present?
      filter_conference_users(params[:user][:conference_users_attributes])
    end

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to(person_user_path(@person), notice: 'User was successfully updated.') }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /users/1
  def destroy
    authorize UserConferenceContext.new(user: @user, conference: @conference)
  end

  private

  def user_params
    params.require(:user).permit(:id, :role, :email, :password, :password_confirmation,
      conference_users_attributes: %i(id role conference_id _destroy))
  end

  def authorize_manage_user
    authorize UserConferenceContext.new(user: @user, conference: @conference), :manage?
  end

  def set_allowed_user_roles(role, fallback=nil)
    if current_user.is_admin?
      @user.role = role
    elsif policy(@conference).orga? && User::USER_ROLES.include?(role)
      @user.role = role
    elsif fallback
      @user.role = fallback
    end
  end

  def ensure_user
    redirect_to new_person_user_path(@person) unless @user
  end

  def find_person
    @person = Person.find(params[:person_id])
    @user = @person.user
  end

  def filter_conference_users(conference_users)
    orga_conference_users = policy_scope(@user.conference_users)
    orga_conferences = orga_conference_users.map(&:conference_id)
    conference_users.delete_if do |id, conference_user|
      conference_id = conference_user[:conference_id]
      conference_id.nil? || !orga_conferences.include?(conference_id)
    end
  end
end

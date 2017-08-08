class UsersController < BaseCrewController
  before_action :find_person
  before_action :authorize_person_user, except: %i[new create]
  before_action :ensure_user, except: %i[new create]
  layout :layout_if_conference

  # GET /users/1
  # GET /users/1.xml
  def show
  end

  # GET /users/new
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user.conference_users = policy_scope(@user.conference_users)
  end

  # POST /users
  def create
    @user = authorize User.new(user_params)

    set_allowed_user_roles(user_params[:role], 'submitter')
    @user.person = @person
    @user.skip_confirmation!

    respond_to do |format|
      if @user.save
        format.html { redirect_to(edit_person_user_path(@person), notice: 'User was successfully created.') }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /users/1
  def update
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
        @user.confirm unless @user.confirmed?
        bypass_sign_in(@user) if current_user == @user
        format.html { redirect_to(edit_crew_user_path(@person), notice: 'User was successfully updated.') }
      else
        flash[:errors] = @user.errors.full_messages.join
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /users/1
  def destroy
  end

  private

  def user_params
    params.require(:user).permit(:id, :role, :email, :password, :password_confirmation,
      conference_users_attributes: %i(id role conference_id _destroy))
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
    return if current_user.is_admin?
    redirect_to new_person_user_path(@person) unless @user
  end

  def find_person
    @person = Person.find(params[:person_id])
  end

  def authorize_person_user
    @user = authorize @person.user
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

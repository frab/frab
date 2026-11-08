class UsersController < BaseCrewController
  before_action :find_person
  before_action :authorize_person_user, except: %i[new create]
  before_action :ensure_user, except: %i[new create]
  layout :layout_if_conference

  # GET /users/1
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
    # Don't assign this to @user.conference_users: that deletes the other rows.
    @conference_users = policy_scope(@user.conference_users)
  end

  # POST /users
  def create
    filter_conference_users(params[:user][:conference_users_attributes]) unless current_user.is_admin?
    @user = authorize User.new(user_params)

    set_allowed_user_roles(user_params[:role], 'submitter')
    @user.person = @person
    @user.skip_confirmation!

    respond_to do |format|
      if @user.save
        format.html { redirect_to(edit_person_user_path(@person), notice: t('users_module.notice_user_created')) }
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

    unless current_user.is_admin?
      filter_conference_users(params[:user][:conference_users_attributes])
      protect_foreign_user(params[:user])
    end

    set_allowed_user_roles(params[:user][:role])
    params[:user].delete(:role)

    respond_to do |format|
      if params[:user].present? and @user.update(user_params)
        if @user.respond_to?(:confirm)
          @user.confirm unless @user.confirmed?
        end
        bypass_sign_in(@user) if current_user == @user
        format.html { redirect_to(edit_crew_user_path(@person), notice: t('users_module.notice_user_updated')) }
      else
        flash_model_errors(@user)
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

  def assign_user_role?(role)
    policy(Conference).orga? && User::USER_ROLES.include?(role)
  end

  def set_allowed_user_roles(role, fallback=nil)
    if current_user.is_admin?
      @user.role = role
    elsif assign_user_role?(role)
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

  # Drop any conference role grant the current user is not entitled to make.
  # Managing a conference's crew is an orga-only power, so only rows for
  # conferences the current user organizes survive. For existing rows the
  # authoritative conference is the stored one, not the submitted parameter,
  # so a spoofed conference_id cannot move or destroy a foreign grant. Existing
  # rows may not be moved to another conference at all.
  def filter_conference_users(conference_users)
    return if conference_users.blank?

    orga_conference_ids = current_user.organizes_conferences.map(&:conference_id)
    conference_users.delete_if do |_, attributes|
      conference_id = target_conference_id(attributes)
      conference_id.nil? || orga_conference_ids.exclude?(conference_id) ||
        moves_conference?(attributes, conference_id)
    end
  end

  def target_conference_id(attributes)
    if attributes[:id].present?
      ConferenceUser.where(id: attributes[:id]).pick(:conference_id)
    else
      attributes[:conference_id].presence&.to_i
    end
  end

  def moves_conference?(attributes, stored_conference_id)
    submitted = attributes[:conference_id].presence&.to_i
    attributes[:id].present? && submitted.present? && submitted != stored_conference_id
  end

  # An orga may add roles on their own conferences to any user, but must not
  # change the credentials or global role of a user who belongs to a conference
  # the orga does not organize -- resetting that user's password would hand the
  # orga access to those other conferences. Editing one's own account, or a user
  # affiliated only with the orga's own conferences, stays unrestricted.
  def protect_foreign_user(attributes)
    return if current_user == @user
    return unless foreign_user?(@user)

    attributes.delete(:email)
    attributes.delete(:password)
    attributes.delete(:password_confirmation)
    attributes.delete(:role)
  end

  def foreign_user?(user)
    orga_conference_ids = current_user.organizes_conferences.map(&:conference_id)
    user.conference_users.where.not(conference_id: orga_conference_ids).exists?
  end
end

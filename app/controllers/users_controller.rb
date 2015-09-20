class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  before_action :find_person

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = @person.user
    can_manage_user!

    redirect_to new_person_user_path(@person) unless @user
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    can_manage_user!

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = @person.user
    can_manage_user!

    @user.conference_users.to_a.select! { |cu|
      can? :assign_user_roles, cu.conference
    }
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(user_params)
    can_manage_user!

    if can? :assign_roles, User
      @user.role = user_params[:role]
    else
      @user.role = 'submitter'
    end
    @user.person = @person
    @user.skip_confirmation!

    respond_to do |format|
      if @user.save
        format.html { redirect_to(person_user_path(@person), notice: 'User was successfully created.') }
        format.xml  { render xml: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = @person.user
    can_manage_user!

    [:password, :password_confirmation].each do |password_key|
      params[:user].delete(password_key) if params[:user][password_key].blank?
    end

    # user.role
    if can? :assign_roles, User
      @user.role = params[:user][:role]
    elsif can_only_manage_crew_roles
      role = params[:user][:role]
      @user.role = role if User::USER_ROLES.include? role
    end
    params[:user].delete(:role)

    # user.conference_users
    if can_only_manage_crew_roles and params[:user][:conference_users_attributes].present?
      filter_conference_users(params[:user][:conference_users_attributes])
    end

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to(person_user_path(@person), notice: 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
  end

  private

  def user_params
    params.require(:user).permit(:id, :role, :email, :password, :password_confirmation,
                                conference_users_attributes: %i(id role conference_id _destroy))
  end

  def can_manage_user!
    if @user.nil? or @user.id.nil?
      authorize! :administrate, User
    else
      authorize! :crud, @user
    end
  end

  def can_only_manage_crew_roles
    cannot? :assign_roles, User and can? :assign_user_roles, User
  end

  def find_person
    @person = Person.find(params[:person_id])
  end

  def filter_conference_users(conference_users)
    delete = []
    conference_users.each do |id, conference_user|
      if conference_user.key?(:conference_id) and conference_user[:conference_id].present?
        conference = Conference.find conference_user[:conference_id]
        delete << id unless can? :assign_user_roles, conference
      else
        delete << id
      end
    end

    delete.each { |p| conference_users.delete(p) }
  end
end

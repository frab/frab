class UsersController < ApplicationController

  before_filter :find_person

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = @person.user

    redirect_to new_person_user_path(@person) unless @user
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = @person.user 
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.person = @person
    @user.skip_confirmation!

    respond_to do |format|
      if @user.save
        format.html { redirect_to(person_user_path(@person), :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = @person.user 
    [:password, :password_confirmation].each do |password_key|
      params[:user].delete(password_key) if params[:user][password_key].blank?
    end
    @user.role = params[:user][:role]

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(person_user_path(@person), :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
  end

end

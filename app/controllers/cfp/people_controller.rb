class Cfp::PeopleController < ApplicationController

  layout "cfp"

  before_filter :authenticate_user!
  before_filter :check_cfp_open
  load_and_authorize_resource :person, :parent => false

  def show
    @person = current_user.person

    redirect_to :action => "new" unless @person
  end

  def new
    @person = Person.new(:email => current_user.email)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  def edit
    @person = current_user.person 
  end

  def create
    @person = Person.new(params[:person])
    @person.user = current_user

    respond_to do |format|
      if @person.save
        format.html { redirect_to(cfp_person_path, :notice => t("cfp.person_created_notice")) }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @person = current_user.person 

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(cfp_person_path, :notice => t("cfp.person_updated_notice")) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

end

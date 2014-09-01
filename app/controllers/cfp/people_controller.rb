class Cfp::PeopleController < ApplicationController

  layout "cfp"

  before_filter :authenticate_user!
  before_filter :check_cfp_open

  def show
    @person = current_user.person

    if not @conference.in_the_past and @person.events_in(@conference).size > 0 and @person.availabilities_in(@conference).count == 0
      flash[:alert] = t("cfp.specify_availability") 
    end

    return redirect_to :action => "new" unless @person
    if @person.public_name == current_user.email
      flash[:alert] = "Your email address is not a valid public name, please change it."
      redirect_to :action => "edit"
    end
  end

  def new
    @person = Person.new(email: current_user.email)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @person }
    end
  end

  def edit
    @person = current_user.person 
    if @person.nil?
      flash[:alert] = "Not a valid person"
      return redirect_to action: :index
    end
  end

  def create
    @person = current_user.person 
    if @person.nil?
      @person = Person.new(params[:person])
      @person.user = current_user
    end

    respond_to do |format|
      if @person.save
        format.html { redirect_to(cfp_person_path, notice: t("cfp.person_created_notice")) }
        format.xml  { render xml: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @person = current_user.person 

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(cfp_person_path, notice: t("cfp.person_updated_notice")) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

end

class AvailabilitiesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :person, :parent => false
  before_filter :find_person

  def new
    # authorize! :create, @person
    @availabilities = Availability.build_for(@conference)
  end

  def edit
    @availabilities = @person.availabilities_in(@conference)
    @availabilities.each { |a|
      a.start_date = a.start_date.in_time_zone
      a.end_date = a.end_date.in_time_zone
    }
  end

  def update
    # remove empty availabilities
    params[:person]['availabilities_attributes'].each { |k,v| 
      Availability.delete(v['id']) if v['start_date'].to_i == -1
    }
    params[:person]['availabilities_attributes'].select! { |k,v| v['start_date'].to_i > 0 }
    # fix dates
    params[:person]['availabilities_attributes'].each { |k,v|
      v['start_date']  = Time.zone.parse(v['start_date'])
      v['end_date']  = Time.zone.parse(v['end_date'])
    }

    @person.update_attributes(params[:person])
    redirect_to(person_url(@person), :notice => 'Availibility was successfully updated.')
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
  end

end

class PentabarfImportHelper

  class Pentabarf < ActiveRecord::Base
    self.establish_connection(:pentabarf)
  end

  def initialize
    @barf = Pentabarf.connection
  end

  def import_conferences
    conferences = @barf.select_all("SELECT * FROM conference")
    @conference_mapping = Hash.new
    conferences.each do |conference|
      first_day = @barf.select_value("SELECT conference_day FROM conference_day WHERE conference_id = #{conference["conference_id"]} ORDER BY conference_day ASC LIMIT 1")
      last_day = @barf.select_value("SELECT conference_day FROM conference_day WHERE conference_id = #{conference["conference_id"]} ORDER BY conference_day DESC LIMIT 1")
      new_conference = Conference.create!(
        :title => conference["title"],
        :acronym => conference["acronym"],
        #TODO might need mapping to something rails understands
        :timezone => conference["timezone"],
        #TODO
        :timeslot_duration => conference["timeslot_duration"],
        :default_timeslots => conference["default_timeslots"],
        :max_timeslots => conference["max_timeslot_duration"],
        :feedback_enabled => conference["f_feedback_enabled"],
        :first_day => first_day,
        :last_day => last_day
      )
      @conference_mapping[conference["conference_id"]] = new_conference.id
    end
  end

  def import_people
    people = @barf.select_all("SELECT * FROM person")
    @people_mapping = Hash.new
    people.each do |person|
      abstract, description = @barf.select_values("SELECT abstract, description FROM conference_person WHERE person_id = #{person["person_id"]} ORDER BY conference_person_id DESC")
      new_person = Person.create!(
        :first_name => person["first_name"] ? person["first_name"] : "unknown",
        :last_name => person["last_name"] ? person["last_name"] : "unknown",
        :public_name => person["public_name"],
        :email => person["email"] ? person["email"] : "unknown",
        :gender => person["gender"] ? "male" : "female",
        :abstract => abstract,
        :description => description
      )
      @people_mapping[person["person_id"]] = new_person.id
    end
  end

  def import_events
    events = @barf.select_all("SELECT * FROM event")
    @event_mapping = Hash.new
    events.each do |event|
      new_event = Event.create!(
        :conference_id => @conference_mapping[event["conference_id"]],
        :title => event["title"],
        :subtitle => event["subtitle"],
        :event_type => event["event_type"],
        #TODO
        :time_slots => event["duration"],
        :state => event["event_state"],
        :progress => event["event_state_progress"],
        #TODO 
        :language => event["language"],
        #TODO
        :start_time => event["start_time"],
        :abstract => event["abstract"],
        :description => event["description"],
        :public => event["public"]
      )
      @event_mapping[event["event_id"]] = new_event.id
    end
  end

  def import_event_people
    event_people = @barf.select_all("SELECT * FROM event_person")
    event_people.each do |event_person|
      EventPerson.create!(
        :event_id => @event_mapping[event_person["event_id"]],
        :person_id => @event_mapping[event_person["person_id"]],
        :event_role => event_person["event_role"],
        :role_state => event_person["event_role_state"],
        :comment => event_person["remark"]
      )
    end
  end

end

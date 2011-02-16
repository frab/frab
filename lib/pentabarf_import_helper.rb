class PentabarfImportHelper
    
  FILE_TYPES = { "image/jpeg" => "jpg", "image/png" => "png", "image/gif" => "gif" }

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
      image = @barf.select_one("SELECT * FROM person_image WHERE person_id = #{person["person_id"]}")
      image_file = image_to_file(image, "person_id")
      new_person = Person.create!(
        :first_name => person["first_name"].blank? ? "unknown" : person["first_name"],
        :last_name => person["last_name"].blank? ? "unknown" : person["last_name"],
        :public_name => person["public_name"],
        :email => person["email"].blank? ? "unknown" : person["email"],
        :gender => person["gender"] ? "male" : "female",
        :abstract => abstract,
        :description => description,
        :avatar => image_file
      )
      remove_image(image_file)
      @people_mapping[person["person_id"]] = new_person.id
    end
  end

  def import_events
    events = @barf.select_all("SELECT * FROM event")
    @event_mapping = Hash.new
    events.each do |event|
      image = @barf.select_one("SELECT * FROM event_image WHERE event_id = #{event["event_id"]}")
      image_file = image_to_file(image, "event_id")
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
        :public => event["public"],
        :logo => image_file
      )
      remove_image(image_file)
      @event_mapping[event["event_id"]] = new_event.id
    end
  end

  def import_event_people
    event_people = @barf.select_all("SELECT * FROM event_person")
    event_people.each do |event_person|
      EventPerson.create!(
        :event_id => @event_mapping[event_person["event_id"]],
        :person_id => @people_mapping[event_person["person_id"]],
        :event_role => event_person["event_role"],
        :role_state => event_person["event_role_state"],
        :comment => event_person["remark"]
      )
    end
  end

  private

  def image_to_file(image, id_column)
    if image
      file_name = "tmp/#{image[id_column]}.#{FILE_TYPES[image["mime_type"]]}"
      File.open(file_name, "w:ASCII-8BIT") {|f| f.write(image["image"]) }
      file = File.open(file_name, "r")
      return file
    end
    return nil
  end

  def remove_image(file)
    if file
      file.close
      File.unlink(file.path)
    end
  end
end

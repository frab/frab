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
    conference_mapping = create_mappings(:conferences) 
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
      conference_mapping[conference["conference_id"]] = new_conference.id
    end
    save_mappings(:conferences)
  end

  def import_tracks
    track_mapping = create_mappings(:tracks)
    tracks = @barf.select_all("SELECT * FROM conference_track")
    tracks.each do |track|
      new_track = Track.create!(
        :name => track["conference_track"],
        :conference_id => mappings(:conferences)[track["conference_id"]]
      )
      track_mapping[track["conference_track_id"]] = new_track.id
    end
    save_mappings(:tracks)
  end

  def import_rooms
    room_mapping = create_mappings(:rooms)
    rooms = @barf.select_all("SELECT * FROM conference_room")
    rooms.each do |room|
      new_room = Room.create!(
        :name => room["conference_room"],
        :size => room["size"],
        :public => room["public"],
        :conference_id => mappings(:conferences)[room["conference_id"]]
      )
      room_mapping[room["conference_room_id"]] = new_room.id
    end
    save_mappings(:rooms)
  end

  def import_people
    people = @barf.select_all("SELECT * FROM person")
    people_mapping = create_mappings(:people) 
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
      people_mapping[person["person_id"]] = new_person.id
    end
    save_mappings(:people)
    phone_numbers = @barf.select_all("SELECT * FROM person_phone")
    phone_numbers.each do |phone_number|
      PhoneNumber.create!(
        :person_id => people_mapping[phone_number["person_id"]],
        :phone_type => phone_number["phone_type"],
        :phone_number => phone_number["phone_number"]
      )
    end
    im_accounts = @barf.select_all("SELECT * FROM person_im")
    im_accounts.each do |im_account|
      ImAccount.create!(
        :person_id => people_mapping[im_account["person_id"]],
        :im_type => im_account["im_type"],
        :im_address => im_account["im_address"]
      )
    end
  end

  def import_links
    mappings(:people).each do |orig_id, new_id|
      links = @barf.select_all("SELECT l.title, l.url FROM conference_person as p LEFT OUTER JOIN conference_person_link as l ON p.conference_person_id = l.conference_person_id WHERE p.person_id = #{orig_id}")
      links.each do |link|
        if link["title"] and link["url"]
          person = Person.find(new_id)
          Link.create(:title => link["title"], :url => link["url"], :linkable => person)
        end
      end
    end
    mappings(:events).each do |orig_id, new_id|
      links = @barf.select_all("SELECT title, url FROM event_link WHERE event_id = #{orig_id}")
      links.each do |link|
        if link["title"] and link["url"]
          event = Event.find(new_id)
          Link.create(:title => link["title"], :url => link["url"], :linkable => event)
        end
      end
    end
  end

  def import_events
    events = @barf.select_all("SELECT * FROM event")
    event_mapping = create_mappings(:events) 
    events.each do |event|
      image = @barf.select_one("SELECT * FROM event_image WHERE event_id = #{event["event_id"]}")
      image_file = image_to_file(image, "event_id")
      new_event = Event.create!(
        :conference_id => mappings(:conferences)[event["conference_id"]],
        :track_id => mappings(:tracks)[event["conference_track_id"]],
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
        :room_id => mappings(:rooms)[event["conference_room_id"]],
        :abstract => event["abstract"],
        :description => event["description"],
        :public => event["public"],
        :logo => image_file
      )
      remove_image(image_file)
      event_mapping[event["event_id"]] = new_event.id
    end
    save_mappings(:events)
  end

  def import_event_people
    event_people = @barf.select_all("SELECT * FROM event_person")
    event_people.each do |event_person|
      EventPerson.create!(
        :event_id => mappings(:events)[event_person["event_id"]],
        :person_id => mappings(:people)[event_person["person_id"]],
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
  
  def mappings(name)
    @mappings = Hash.new unless @mappings
    if !@mappings[name] and File.exist?(mappings_file(name))
      @mappings[name] = YAML.load_file(mappings_file(name))
    elsif !@mappings[name]
      raise "No mappings to load. Please run a full import."
    end
    return @mappings[name] if @mappings[name]
  end

  def create_mappings(name)
    @mappings = Hash.new unless @mappings
    @mappings[name] = Hash.new
  end

  def save_mappings(name)
    if @mappings and @mappings[name]
      File.open(mappings_file(name), "w") {|f| YAML.dump(@mappings[name], f)}
    end
  end

  def mappings_file(name)
    File.join(RAILS_ROOT, "tmp", "#{name}_mappings.yml")
  end
end

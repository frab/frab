class ImportExportHelper
  DEBUG=true
  EXPORT_DIR="tmp/frab_export"

  def initialize(conference=nil)
    @export_dir = EXPORT_DIR
    @conference = conference
    PaperTrail.enabled = false
  end

  # everything except: RecentChanges
  def run_export
    if @conference.nil?
      puts "[!] the conference wasn't found."
      exit 
    end

    FileUtils.mkdir_p(@export_dir)

    dump "conference", @conference
    dump "conference_tracks", @conference.tracks
    dump "conference_cfp", @conference.call_for_papers
    dump "conference_ticket_server", @conference.ticket_server
    dump "conference_rooms", @conference.rooms
    dump "conference_days", @conference.days
    dump "conference_languages", @conference.languages
    dump "events", @conference.events
    dump_has_many "tickets", @conference.events, 'ticket'
    dump_has_many "event_people", @conference.events, 'event_people'
    dump_has_many "event_feedbacks", @conference.events, 'event_feedbacks'
    people = dump_has_many "people", @conference.events, 'people'
    dump_has_many "event_links", @conference.events, 'links'
    attachments = dump_has_many "event_attachments", @conference.events, 'event_attachments'
    export_attachments(attachments)
    dump_has_many "event_ratings", @conference.events, 'event_ratings'
    dump_has_many "conflicts", @conference.events, 'conflicts'
    #dump_has_many "conflicts_as_conflicting", @conference.events, 'conflicts_as_conflicting'
    dump_has_many "people_phone_numbers", people, 'phone_numbers'
    dump_has_many "people_im_accounts", people, 'im_accounts'
    dump_has_many "people_links", people, 'links'
    dump_has_many "people_languages", people, 'languages'
    dump_has_many "people_availabilities", people, 'availabilities'
    dump_has_many "users", people, 'user'
  end

  def run_import(export_dir=EXPORT_DIR)
    @export_dir = export_dir
    disable_callbacks

    # old => new
    @mappings = {
      :conference => {}, :tracks => {}, :cfp => {}, :rooms => {}, :days => {},
      :people => {}, :users => {},
      :events => {}
    }

    restore("conference", Conference) do |id, c|
      test = Conference.find_by_acronym(c.acronym)
      if test
        puts "conference #{c} already exists!"
        exit
      end
      puts "    #{c}" if DEBUG
      c.save!
      @mappings[:conference][id] = c.id
      @conference_id = c.id
    end

    restore_conference_data

    restore_users do |id, yaml, obj|
      user = User.find_by_email(obj.email)
      if user
        # don't create a new user
        @mappings[:users][id] = user.id
      else
        %w{ confirmation_sent_at confirmation_token confirmed_at created_at
            current_sign_in_at current_sign_in_ip last_sign_in_at
            last_sign_in_ip password_digest pentabarf_password
            pentabarf_salt remember_created_at remember_token
            reset_password_token role sign_in_count updated_at
        }.each { |var|
          obj.send("#{var}=",yaml[var])
        }
        obj.call_for_papers_id = @mappings[:cfp][obj.call_for_papers_id]
        obj.confirmed_at ||= Time.now
        obj.save!
        @mappings[:users][id] = obj.id
      end
    end

    restore_multiple("people", Person) do |id, obj|
      person = Person.find_by_email(obj.email)
      if person
        # don't create a new person
        @mappings[:people][id] = person.id
      else
        obj.user_id = @mappings[:users][obj.user_id]
        obj.save!
        @mappings[:people][id] = obj.id
      end
    end

    restore_multiple("events", Event) do |id, obj|
      obj.conference_id =  @conference_id
      obj.track_id = @mappings[:tracks][obj.track_id]
      obj.room_id = @mappings[:rooms][obj.room_id]
      obj.save!
      @mappings[:events][id] = obj.id
    end

    # uses mappings: events, people
    restore_events_data

    # uses mappings: people, days
    restore_people_data
  
    update_counters
    # TODO update_conflicts
  end

  private

  def dump_has_many(name, obj, attr)
    arr = obj.collect { |t| t.send(attr) }
             .flatten.select { |t| not t.nil? }.sort.uniq
    dump name, arr
  end

  def dump(name,obj)
    File.open(File.join(@export_dir, name) + '.yaml', 'w') { |f| 
      if obj.respond_to?("collect")
        f.puts obj.collect {|record| record.attributes}.to_yaml
      else
        f.puts obj.attributes.to_yaml
      end
    }
    return obj
  end

  def restore(name, obj)
    puts "[ ] restore #{name}" if DEBUG
    records = YAML.load_file(File.join(@export_dir, name) + '.yaml')
    tmp = obj.new(records)
    yield records['id'], tmp
  end

  def restore_multiple(name, obj)
    puts "[ ] restore all #{name}" if DEBUG
    records = YAML.load_file(File.join(@export_dir, name) + '.yaml')
    records.each do |record|
      tmp = obj.new(record)
      yield record['id'], tmp
    end
  end

  def restore_users(name="users", obj=User)
    puts "[ ] restore all #{name}" if DEBUG
    records = YAML.load_file(File.join(@export_dir, name) + '.yaml')
    records.each do |record|
      tmp = obj.new(record)
      yield record['id'], record, tmp
    end
  end

  def export_attachments(attachments)
    out_path = File.join(@export_dir, 'attachments')
    FileUtils.mkdir_p out_path
    attachments.each { |a|
      path = File.join('public/assets', a.attachment_file_name)
      if File.readable?(path)
        FileUtils.cp path, out_path
      end
    }
  end

  def import_attachment(attachment_file_name)
    path = File.join(@export_dir, 'attachments', attachment_file_name)
    out_path = File.join('public/assets', attachment_file_name)
    FileUtils.cp path, out_path
  end

  def disable_callbacks
    EventPerson.skip_callback(:save, :after, :update_speaker_count)
    Event.skip_callback(:save, :after, :update_conflicts)
    EventRating.skip_callback(:save, :after, :update_average)
    EventFeedback.skip_callback(:save, :after, :update_average)
  end

  def update_counters
    ActiveRecord::Base.connection.execute("UPDATE events SET speaker_count=(SELECT count(*) FROM event_people WHERE events.id=event_people.event_id AND event_people.event_role='speaker')")
    update_event_average("event_ratings", "average_rating")
    update_event_average("event_feedbacks", "average_feedback")
  end

  def update_event_average(table, field)
    ActiveRecord::Base.connection.execute "UPDATE events SET #{field}=(
       SELECT sum(rating)/count(rating)
       FROM #{table} WHERE events.id = #{table}.event_id)"
  end
   
  def restore_conference_data
    restore_multiple("conference_tracks", Track) do |id, obj|
      obj.conference_id =  @conference_id
      obj.save!
      @mappings[:tracks][id] = obj.id
    end

    restore("conference_cfp", CallForPapers) do |id, obj|
      obj.conference_id =  @conference_id
      obj.save!
      @mappings[:cfp][id] = obj.id
    end

    restore("conference_ticket_server", TicketServer) do |id, obj|
      obj.conference_id =  @conference_id
      obj.save!
    end

    restore_multiple("conference_rooms", Room) do |id, obj|
      obj.conference_id =  @conference_id
      obj.save!
      @mappings[:rooms][id] = obj.id
    end

    restore_multiple("conference_days", Day) do |id, obj|
      obj.conference_id =  @conference_id
      obj.save!
      @mappings[:days][id] = obj.id
    end

    restore_multiple("conference_languages", Language) do |id, obj|
      obj.attachable_id =  @conference_id
      obj.save!
    end
  end

  def restore_events_data
    restore_multiple("tickets", Ticket) do |id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.save!
    end

    restore_multiple("event_people", EventPerson) do |id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.person_id = @mappings[:people][obj.person_id]
      obj.save!
    end

    restore_multiple("event_feedbacks", EventFeedback) do |id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.save!
    end

    restore_multiple("event_ratings", EventRating) do |id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.person_id = @mappings[:people][obj.person_id]
      obj.save!
    end

    restore_multiple("event_links", Link) do |id, obj|
      obj.linkable_id = @mappings[:events][obj.linkable_id]
      obj.save!
    end

    restore_multiple("event_attachments", EventAttachment) do |id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.save!
      import_attachment(obj.attachment_file_name)
    end

    restore_multiple("conflicts", Conflict) do |id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      if obj.conflicting_event_id
        obj.conflicting_event_id = @mappings[:events][obj.conflicting_event_id]
      end
      obj.save!
    end
  end

  def restore_people_data
    restore_multiple("people_phone_numbers", PhoneNumber) do |id, obj|
      new_id = @mappings[:people][obj.person_id]
      test = PhoneNumber.where(:person_id => new_id, :phone_number => obj.phone_number)
      unless test
        obj.person_id = new_id
        obj.save!
      end
    end

    restore_multiple("people_im_accounts", ImAccount) do |id, obj|
      new_id = @mappings[:people][obj.person_id]
      test = ImAccount.where(:person_id => new_id, :im_address => obj.im_address)
      unless test
        obj.person_id = new_id
        obj.save!
      end
    end

    restore_multiple("people_links", Link) do |id, obj|
      new_id = @mappings[:people][obj.linkable_id]
      test = Link.where(:linkable_id => new_id, :linkable_type => obj.linkable_type,
                        :url => obj.url)
      unless test
        obj.linkable_id = new_id
        obj.save!
      end
    end

    restore_multiple("people_languages", Language) do |id, obj|
      new_id = @mappings[:people][obj.attachable_id]
      test = Language.where(:attachable_id => new_id, :attachable_type => obj.attachable_type,
                        :code => obj.code)
      unless test
        obj.attachable_id = new_id
        obj.save!
      end
    end

    restore_multiple("people_availabilities", Availability) do |id, obj|
      next if obj.nil? or obj.start_date.nil? or obj.end_date.nil?
      obj.conference_id = @conference_id
      obj.person_id = @mappings[:people][obj.person_id]
      obj.day_id = @mappings[:days][obj.day_id]
      obj.save!
    end
  end

end

class ImportExportHelper
  DEBUG = true
  EXPORT_DIR = 'tmp/frab_export'.freeze

  def initialize(conference = nil)
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

    ActiveRecord::Base.transaction do
      dump 'conference', @conference
      dump 'conference_tracks', @conference.tracks
      dump 'conference_cfp', @conference.call_for_participation
      dump 'conference_ticket_server', @conference.ticket_server
      dump 'conference_rooms', @conference.rooms
      dump 'conference_days', @conference.days
      dump 'conference_review_metrics', @conference.review_metrics
      dump 'conference_languages', @conference.languages
      events = dump 'events', @conference.events
      dump_has_many 'tickets', @conference.events, 'ticket'
      dump_has_many 'event_people', @conference.events, 'event_people'
      dump_has_many 'event_feedbacks', @conference.events, 'event_feedbacks'
      people = dump_has_many 'people', @conference.events, 'people_involved_or_reviewing'
      dump_has_many 'event_links', @conference.events, 'links'
      attachments = dump_has_many 'event_attachments', @conference.events, 'event_attachments'
      dump_has_many 'event_ratings', @conference.events, 'event_ratings'
      dump_has_many 'event_review_scores', @conference.events, 'review_scores'
      dump_has_many 'people_phone_numbers', people, 'phone_numbers'
      dump_has_many 'people_im_accounts', people, 'im_accounts'
      dump_has_many 'people_links', people, 'links'
      dump_has_many 'people_languages', people, 'languages'
      dump 'people_availabilities', Availability.where(conference: @conference, person: people)
      dump_has_many 'users', people, 'user'
      # TODO languages
      # TODO notifications
      export_paperclip_files(events, people, attachments)
    end
  end

  def run_import(export_dir = EXPORT_DIR)
    @export_dir = export_dir
    unless File.directory? @export_dir
      puts "Directory #{@export_dir} does not exist!"
      exit
    end
    disable_callbacks

    # old => new
    @mappings = {
      conference: {}, tracks: {}, cfp: {}, rooms: {}, days: {}, review_metrics: {},
      people: {}, users: {},
      events: {},
      event_ratings: {},
      people_user: {}
    }

    ActiveRecord::Base.transaction do
      unpack_paperclip_files
      restore_all_data
    end
    
    enable_callbacks
  end

  private

  def restore_all_data
    restore('conference', Conference) do |id, c|
      test = Conference.find_by(acronym: c.acronym)
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

    restore_multiple('people', Person) do |id, obj|
      # TODO could be the wrong person if persons share email addresses!?
      persons = Person.where(email: obj.email, public_name: obj.public_name)
      person = persons.first

      if person
        # don't create a new person
        @mappings[:people][id] = person.id
        @mappings[:people_user][obj.user_id] = person
        if person.avatar.nil? && (file = import_file('people/avatars', id, obj.avatar_file_name))
          person.avatar = file
          person.save
        end
      else
        if (file = import_file('people/avatars', id, obj.avatar_file_name))
          obj.avatar = file
        end
        obj.save!
        @mappings[:people][id] = obj.id
        @mappings[:people_user][obj.user_id] = obj
      end
    end

    restore_users do |id, yaml, obj|
      user = User.find_by(email: obj.email)
      if user
        # don't create a new user
        @mappings[:users][id] = user.id
      else
        %w( confirmation_sent_at confirmation_token confirmed_at created_at
            current_sign_in_at current_sign_in_ip last_sign_in_at
            last_sign_in_ip encrypted_password
            remember_created_at remember_token
            provider uid
            reset_password_token role sign_in_count updated_at).each { |var|
          obj.send("#{var}=", yaml[var])
        }
        obj.confirmed_at ||= Time.now
        obj.person = @mappings[:people_user][id]
        obj.save(validate: false)
        @mappings[:users][id] = obj.id
      end
    end

    restore_multiple('events', Event) do |id, obj|
      obj.conference_id = @conference_id
      obj.track_id = @mappings[:tracks][obj.track_id]
      obj.room_id = @mappings[:rooms][obj.room_id]
      if (file = import_file('events/logos', id, obj.logo_file_name))
        obj.logo = file
      end
      obj.regenerate_invite_token if Event.where(invite_token: obj.invite_token).any?
      obj.save!
      @mappings[:events][id] = obj.id
    end

    # updates the mappings: event_ratings
    # uses mappings: events, people
    restore_events_data

    # uses mappings: people, days
    restore_people_data

    update_counters
    Event.all.each(&:update_conflicts)
  end

  def restore_conference_data
    restore_multiple('conference_tracks', Track) do |id, obj|
      obj.conference_id = @conference_id
      obj.save!
      @mappings[:tracks][id] = obj.id
    end

    restore('conference_cfp', CallForParticipation) do |_id, obj|
      obj.conference_id = @conference_id
      obj.save!
    end

    restore('conference_ticket_server', TicketServer) do |_id, obj|
      obj.conference_id = @conference_id
      obj.save!
    end

    restore_multiple('conference_rooms', Room) do |id, obj|
      obj.conference_id = @conference_id
      obj.save!
      @mappings[:rooms][id] = obj.id
    end

    restore_multiple('conference_days', Day) do |id, obj|
      obj.conference_id = @conference_id
      obj.save!
      @mappings[:days][id] = obj.id
    end

    restore_multiple('conference_languages', Language) do |_id, obj|
      obj.attachable_id = @conference_id
      obj.save!
    end
        
    restore_multiple('conference_review_metrics', ReviewMetric) do |id, obj|
      obj.conference_id = @conference_id
      obj.save!
      @mappings[:review_metrics][id] = obj.id
    end

  end

  def restore_events_data
    restore_multiple('tickets', Ticket) do |_id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.save!
    end

    restore_multiple('event_people', EventPerson) do |_id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.person_id = @mappings[:people][obj.person_id]
      obj.save!
    end

    restore_multiple('event_feedbacks', EventFeedback) do |_id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.save!
    end

    restore_multiple('event_ratings', EventRating) do |_id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      obj.person_id = @mappings[:people][obj.person_id]
      obj.save! if obj.valid?
      @mappings[:event_ratings][_id] = obj.id
    end

    restore_multiple('event_review_scores', ReviewScore) do |_id, obj|
      obj.event_rating_id = @mappings[:event_ratings][obj.event_rating_id]
      obj.review_metric_id = @mappings[:review_metrics][obj.review_metric_id]
      obj.save! if obj.valid?
    end

    restore_multiple('event_links', Link) do |_id, obj|
      obj.linkable_id = @mappings[:events][obj.linkable_id]
      obj.save!
    end

    restore_multiple('event_attachments', EventAttachment) do |id, obj|
      obj.event_id = @mappings[:events][obj.event_id]
      if (file = import_file('event_attachments/attachments', id, obj.attachment_file_name))
        obj.attachment = file
      end
      obj.save!
    end
  end

  def restore_people_data
    restore_multiple('people_phone_numbers', PhoneNumber) do |_id, obj|
      new_id = @mappings[:people][obj.person_id]
      test = PhoneNumber.where(person_id: new_id, phone_number: obj.phone_number)
      unless test
        obj.person_id = new_id
        obj.save!
      end
    end

    restore_multiple('people_im_accounts', ImAccount) do |_id, obj|
      new_id = @mappings[:people][obj.person_id]
      test = ImAccount.where(person_id: new_id, im_address: obj.im_address)
      unless test
        obj.person_id = new_id
        obj.save!
      end
    end

    restore_multiple('people_links', Link) do |_id, obj|
      new_id = @mappings[:people][obj.linkable_id]
      test = Link.where(linkable_id: new_id, linkable_type: obj.linkable_type,
                        url: obj.url)
      unless test
        obj.linkable_id = new_id
        obj.save!
      end
    end

    restore_multiple('people_languages', Language) do |_id, obj|
      new_id = @mappings[:people][obj.attachable_id]
      test = Language.where(attachable_id: new_id, attachable_type: obj.attachable_type,
                            code: obj.code)
      unless test
        obj.attachable_id = new_id
        obj.save!
      end
    end

    restore_multiple('people_availabilities', Availability) do |_id, obj|
      next if obj.nil? or obj.start_date.nil? or obj.end_date.nil?
      obj.conference_id = @conference_id
      obj.person_id = @mappings[:people][obj.person_id]
      obj.day_id = @mappings[:days][obj.day_id]
      obj.save!
    end
  end

  def dump_has_many(name, obj, attr)
    arr = obj.collect { |t| t.send(attr) }
      .flatten.select { |t| not t.nil? }.sort.uniq
    dump name, arr
  end

  def dump(name, obj)
    return if obj.nil?
    File.open(File.join(@export_dir, name) + '.yaml', 'w') { |f|
      if obj.respond_to?('collect')
        f.puts obj.collect(&:attributes).to_yaml
      else
        f.puts obj.attributes.to_yaml
      end
    }
    obj
  end

  def restore(name, obj)
    puts "[ ] restore #{name}" if DEBUG
    file = File.join(@export_dir, name) + '.yaml'
    return unless File.readable? file
    records = YAML.load_file(file)
    tmp = obj.new(records)
    tmp.id = nil
    yield records['id'], tmp
  end

  def restore_multiple(name, obj)
    puts "[ ] restore all #{name}" if DEBUG
    records = YAML.load_file(File.join(@export_dir, name) + '.yaml')
    records.each do |record|
      tmp = obj.new(record)
      tmp.id = nil
      yield record['id'], tmp
    end
  end

  def restore_users(name = 'users', obj = User)
    puts "[ ] restore all #{name}" if DEBUG
    records = YAML.load_file(File.join(@export_dir, name) + '.yaml')
    records.each do |record|
      tmp = obj.new(record)
      tmp.id = nil
      yield record['id'], record, tmp
    end
  end

  def export_paperclip_files(events, people, attachments)
    out_path = File.join(@export_dir, 'attachments.tar.gz')

    paths = []
    paths << events.reject { |e| e.logo.path.nil? }.collect { |e| e.logo.path.gsub(/^#{Rails.root}\//, '') }
    paths << people.reject { |e| e.avatar.path.nil? }.collect { |e| e.avatar.path.gsub(/^#{Rails.root}\//, '') }
    paths << attachments.reject { |e| e.attachment.path.nil? }.collect { |e| e.attachment.path.gsub(/^#{Rails.root}\//, '') }
    paths.flatten!

    # TODO don't use system
    system('tar', *['-cpz', '-f', out_path, paths].flatten)
  end

  def import_file(dir, id, file_name)
    return unless file_name.present?

    # ':rails_root/public/system/:class/:attachment/:id_partition/:style/:filename'
    id_partition = ('%09d'.freeze % id).scan(/\d{3}/).join('/'.freeze)
    path = File.join(@export_dir, 'public/system', dir, id_partition, 'original', file_name)
    return File.open(path, 'r') if File.readable?(path)

    nil
  end

  def unpack_paperclip_files
    path = File.join(@export_dir, 'attachments.tar.gz')
    system('tar', *['-xz', '-f', path, '-C', @export_dir].flatten)
  end

  def disable_callbacks
    EventPerson.skip_callback(:save, :after, :update_speaker_count)
    Event.skip_callback(:save, :after, :update_conflicts)
    Availability.skip_callback(:save, :after, :update_event_conflicts)
    EventRating.skip_callback(:save, :after, :update_average)
    EventFeedback.skip_callback(:save, :after, :update_average)
  end
  
  def enable_callbacks
    EventPerson.set_callback(:save, :after, :update_speaker_count)
    Event.set_callback(:save, :after, :update_conflicts)
    Availability.set_callback(:save, :after, :update_event_conflicts)
    EventRating.set_callback(:save, :after, :update_average)
    EventFeedback.set_callback(:save, :after, :update_average)
  end
  
  def update_counters
    ActiveRecord::Base.connection.execute("UPDATE events SET speaker_count=(SELECT count(*) FROM event_people WHERE events.id=event_people.event_id AND event_people.event_role='speaker')")
    update_event_average('event_ratings', 'average_rating')
    update_event_average('event_feedbacks', 'average_feedback')
    Event.all.each(&:recalculate_review_averages!)
  end

  def update_event_average(table, field)
    ActiveRecord::Base.connection.execute "UPDATE events SET #{field}=(
       SELECT sum(rating)/count(rating)
       FROM #{table} WHERE events.id = #{table}.event_id)"
  end
end

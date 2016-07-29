class PentabarfImportHelper
  DEBUG = true

  # maps mime types from pentabarf to file extensions
  FILE_TYPES = {
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/gif' => 'gif'
  }

  DUMMY_MAIL = 'root@localhost.localdomain'

  # pentabarf roles are just different
  ROLE_MAPPING = {
    'submitter' => 'submitter',
    'reviewer' => 'reviewer',
    'comittee' => 'coordinator',
    'admin' => 'orga',
    'developer' => 'admin'
  }

  EVENT_STATE_MAPPING = {
    'undecided' => 'unconfirmed',
    'rejected' => 'rejected',
    'accepted' => 'confirmed'
  }

  # as in User
  EMAIL_REGEXP = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  class Pentabarf < ActiveRecord::Base
    self.establish_connection(:pentabarf)
  end

  def initialize
    @barf = Pentabarf.connection
    PaperTrail.enabled = false
  end

  def import_conferences
    conferences = @barf.select_all('SELECT * FROM conference')
    puts "[ ] importing #{conferences.count} conferences" if DEBUG
    conference_mapping = create_mappings(:conferences)

    conferences.each do |conference|
      penta_days = @barf.select_values("SELECT conference_day FROM conference_day
                                      WHERE conference_id = #{conference['conference_id']}
                                      ORDER BY conference_day ASC")

      fake_days = penta_days
      fake_days << Time.now.ago(1.year) if fake_days.empty?

      new_conference = Conference.create!(
        title: conference['title'],
        # clean up acronyms in pentabarf db first!
        acronym: conference['acronym'].delete(' '),
        # it's a string like 'Europe/Berlin', 'Berlin'
        timezone: conference['timezone'],
        timeslot_duration: interval_to_minutes(conference['timeslot_duration']),
        default_timeslots: conference['default_timeslots'],
        max_timeslots: conference['max_timeslot_duration'],
        feedback_enabled: penta_bool(conference['f_feedback_enabled']),
        # nowhere to find. just use the conference dates instead..
        created_at: fake_days.first.to_datetime,
        updated_at: fake_days.last.to_datetime,
      # TODO ticket server, instead of link? DO TICKET URLS THEY END UP PUBLIC?
      )
      conference_mapping[conference['conference_id']] = new_conference.id

      # use the conference time zone from now on
      Time.zone = new_conference.timezone
      # puts "+++ %s - %s" % [conference["acronym"], Time.zone] if DEBUG

      # convert pentabarf days to frab days
      penta_days.each do |day|
        day = day.to_datetime
        # pentabarf uses a 'day change time',
        # which is set at 04:00 o'clock for ccc congresses
        # so we kind of fix it:
        hour = conference['day_change'].gsub(/:.*/, '').to_i

        start_date = day.to_datetime.change(hour: hour, minute: 0)
        end_date = day.since(1.days).to_datetime.change(hour: hour - 1, minute: 59)
        tmp = Day.new(conference: new_conference,
                      start_date: Time.zone.local_to_utc(start_date),
                      end_date: Time.zone.local_to_utc(end_date))
        tmp.save!
      end

      # create a dummy cfp for this conference
      cfp = CallForParticipation.new
      cfp.conference = new_conference
      cfp.start_date = fake_days.first.to_datetime.ago(3.month)
      cfp.end_date = fake_days.first.to_datetime.ago(1.month)
      cfp.created_at = cfp.start_date
      cfp.updated_at = cfp.end_date
      cfp.info_url = conference['homepage']
      cfp.contact_email = conference['email']
      cfp.save!
    end
    save_mappings(:conferences)
  end

  def import_tracks
    track_mapping = create_mappings(:tracks)
    tracks = @barf.select_all('SELECT * FROM conference_track')
    puts "[ ] importing #{tracks.count} tracks" if DEBUG
    tracks.each do |track|
      new_track = Track.create!(
        name: track['conference_track'],
        conference_id: mappings(:conferences)[track['conference_id']]
      )
      track_mapping[track['conference_track_id']] = new_track.id
    end
    save_mappings(:tracks)
  end

  def import_rooms
    room_mapping = create_mappings(:rooms)
    rooms = @barf.select_all('SELECT * FROM conference_room')
    puts "[ ] importing #{rooms.count} rooms" if DEBUG
    rooms.each do |room|
      new_room = Room.create!(
        name: room['conference_room'],
        size: room['size'],
        conference_id: mappings(:conferences)[room['conference_id']]
      )
      room_mapping[room['conference_room_id']] = new_room.id
    end
    save_mappings(:rooms)
  end

  def import_people
    people = @barf.select_all('SELECT * FROM person')
    puts "[ ] importing #{people.count} people" if DEBUG
    people_mapping = create_mappings(:people)
    people.each do |person|
      # puts "+++ %d %s - %s" % [person['person_id'], guess_public_name(person), person['email']] if DEBUG
      abstract, description = @barf.select_values("SELECT abstract, description
                                                  FROM conference_person
                                                  WHERE person_id = #{person['person_id']}
                                                  ORDER BY conference_person_id DESC")
      image = @barf.select_one("SELECT * FROM person_image WHERE person_id = #{person['person_id']}")
      image_file = image_to_file(image, 'person_id')
      new_person = Person.create!(
        first_name: person['first_name'].blank? ? '' : person['first_name'],
        last_name: person['last_name'].blank? ? '' : person['last_name'],
        # fun fact: pentabarf has a first_name, last_name, public_name and nickname field
        public_name: guess_public_name(person),
        email: person['email'].blank? ? DUMMY_MAIL : person['email'],
        email_public: 0,
        include_in_mailings: penta_bool(person['spam']),
        gender: guess_gender(person),
        abstract: abstract,
        description: description,
        avatar: image_file
      )
      # don't include dummy addresses in mailings
      new_person.include_in_mailings = false if new_person.email == DUMMY_MAIL
      remove_file(image_file)
      people_mapping[person['person_id']] = new_person.id
    end
    save_mappings(:people)
    phone_numbers = @barf.select_all('SELECT * FROM person_phone')
    phone_numbers.each do |phone_number|
      PhoneNumber.create!(
        person_id: people_mapping[phone_number['person_id']],
        phone_type: phone_number['phone_type'],
        phone_number: phone_number['phone_number']
      )
    end
    im_accounts = @barf.select_all('SELECT * FROM person_im')
    im_accounts.each do |im_account|
      ImAccount.create!(
        person_id: people_mapping[im_account['person_id']],
        im_type: im_account['im_type'],
        im_address: im_account['im_address']
      )
    end
  end

  def import_accounts
    # Alert: This import will skip invalid accounts
    # Additionally, frab requires the email of an account to uniq. pentabarf does not.
    emails = {}
    accounts = @barf.select_all('SELECT * FROM auth.account')
    puts "[ ] importing #{accounts.count} accounts" if DEBUG
    accounts.each do |account|
      # Luckily pentabarf roles ranks match the alphabetical order
      role = @barf.select_value("SELECT role FROM auth.account_role
                              WHERE account_id=#{account['account_id']} ORDER BY role LIMIT 1")
      # do not import if no person is associated
      next if account['person_id'].blank?
      # frab uses email as login, so no user can be created without email
      next if account['email'].blank?
      # Stupid edge case, where validation fails.
      account['email'].sub!(/@localhost$/, '@localhost.localdomain')
      # skip if email is still not valid
      unless account['email'] =~ EMAIL_REGEXP
        puts "!!! invalid email #{account['email']} - pentabarf person_id #{account['person_id']}"
        next
      end

      # TODO decide on proper behaviour for duplicate accounts
      # check for duplicates and rename their mail address
      # if emails[account["email"]]
      #  counter = 1
      #  email = account["email"]
      #  while emails[email]
      #    email = account["email"].sub("@", "#{counter}@")
      #    counter += 1
      #  end
      #  puts "Duplicate email address #{account["email"]} will be imported as #{email} - pentabarf person_id #{account["person_id"]}"
      #  account["email"] = email
      # end

      # instead of the above duplication, skip
      next if emails[account['email']]
      emails[account['email']] = true

      password = (account['login_name'].hash + rand(9999999)).to_s
      User.transaction do
        user = User.new(
          email: account['email'],
          password: password,
          password_confirmation: password
        )
        user.confirmed_at = Time.now
        user.role = role ? ROLE_MAPPING[role] : 'submitter'
        user.pentabarf_salt = account['salt']
        user.pentabarf_password = account['password']
        user.save!
        Person.find(mappings(:people)[account['person_id']]).update_attributes!(user_id: user.id)
      end
    end
  end

  def import_languages
    languages = @barf.select_all('SELECT * FROM conference_language')
    puts "[ ] importing #{languages.count} languages" if DEBUG
    languages.each do |language|
      conference = Conference.find(mappings(:conferences)[language['conference_id']])
      Language.create(code: language['language'], attachable: conference)
    end
    languages = @barf.select_all('SELECT * FROM person_language')
    languages.each do |language|
      person = Person.find(mappings(:people)[language['person_id']])
      Language.create(code: language['language'], attachable: person)
    end
  end

  def import_links
    mappings(:people).each do |orig_id, new_id|
      links = @barf.select_all("SELECT l.title, l.url FROM conference_person as p LEFT OUTER JOIN conference_person_link as l ON p.conference_person_id = l.conference_person_id WHERE p.person_id = #{orig_id}")
      # puts "[ ] importing #{links.count} links from people" if DEBUG
      links.each do |link|
        if link['title'] and link['url']
          person = Person.find(new_id)
          Link.create(title: truncate_string(link['title']),
                      url: truncate_string(link['url']), linkable: person)
        end
      end
    end
    mappings(:events).each do |orig_id, new_id|
      links = @barf.select_all("SELECT title, url FROM event_link WHERE event_id = #{orig_id}")
      # puts "[ ] importing #{links.count} links from events" if DEBUG
      links.each do |link|
        if link['title'] and link['url']
          event = Event.find(new_id)
          Link.create(title: truncate_string(link['title']),
                      url: truncate_string(link['url']), linkable: event)
        end
      end
    end
  end

  def import_events
    events = @barf.select_all('SELECT e.*, c.conference_day FROM event AS e LEFT OUTER JOIN conference_day AS c ON e.conference_day_id = c.conference_day_id')
    puts "[ ] importing #{events.count} events" if DEBUG
    event_mapping = create_mappings(:events)
    events.each do |event|
      image = @barf.select_one("SELECT * FROM event_image WHERE event_id = #{event['event_id']}")
      image_file = image_to_file(image, 'event_id')
      conference = Conference.find(mappings(:conferences)[event['conference_id']])
      Time.zone = conference.timezone

      new_event = Event.create!(
        conference_id: conference.id,
        track_id: mappings(:tracks)[event['conference_track_id']],
        title: event['title'],
        subtitle: truncate_string(event['subtitle']),
        event_type: event['event_type'],
        time_slots: interval_to_minutes(event['duration']) / conference.timeslot_duration,
        # frab does not distinguish in state and progress:
        state: EVENT_STATE_MAPPING[event['event_state']],
        language: event['language'],
        start_time: start_time(event['conference_day'], event['start_time']),
        room_id: mappings(:rooms)[event['conference_room_id']],
        abstract: event['abstract'],
        description: event['description'],
        public: penta_bool(event['public']),
        submission_note: event['submission_notes'],
        note: event['remark'],
        logo: image_file
      )
      remove_file(image_file)
      event_mapping[event['event_id']] = new_event.id
    end
    save_mappings(:events)
  end

  def import_event_ratings
    disable_event_callback(EventRating)

    rating_rankings = Hash.new { |h, v| h[v] = 0 }
    rating_rankings_n = Hash.new { |h, v| h[v] = 0 }
    event_ratings = @barf.select_all('SELECT * FROM event_rating')
    event_ratings.each { |er|
      key = er['person_id'] + '##' + er['event_id']
      rating_rankings[key] += er['rating'].to_i
      rating_rankings_n[key] += 1
    }

    event_ratings = @barf.select_all('SELECT * FROM event_rating_remark')
    puts "[ ] importing #{event_ratings.count} event ratings" if DEBUG
    event_ratings.each do |rating|
      key = rating['person_id'] + '##' + rating['event_id']
      if rating_rankings_n.key?(key)
        score = rating_rankings[key] / rating_rankings_n[key]
      else
        score = 0
      end
      EventRating.create!(
        event_id: mappings(:events)[rating['event_id']],
        person_id: mappings(:people)[rating['person_id']],
        rating: score,
        comment: rating['remark'],
        created_at: rating['eval_time']
      )
    end

    # update in batch
    puts '[ ] updating rating average on events' if DEBUG
    update_event_average('event_ratings', 'average_rating')
    enable_event_callbacks(EventRating)
  end

  def import_event_feedbacks
    disable_event_callback(EventFeedback)

    event_feedbacks = @barf.select_all('SELECT * FROM event_feedback')
    puts "[ ] importing #{event_feedbacks.count} event feedbacks" if DEBUG
    event_feedbacks.each do |feedback|
      # Pentabarf has 3 values, frab only got one, therefore:
      next if %w(topic_importance content_quality presentation_quality audience_involvement remark).all? { |c| feedback[c].blank? }
      rating = 0
      rating_count = 0
      %w(topic_importance content_quality presentation_quality audience_involvement).each do |rating_column|
        next if feedback[rating_column].blank?
        rating_count += 1
        rating += feedback[rating_column].to_f
      end
      if rating_count == 0
        rating = nil
      else
        rating /= rating_count.to_f
      end
      # this might happen:
      rating = 3 if rating.nil?
      EventFeedback.create!(
        event_id: mappings(:events)[feedback['event_id']],
        rating: rating,
        comment: feedback['remark'],
        created_at: feedback['eval_time']
      )
    end

    # update in batch
    puts '[ ] updating feedback average on events' if DEBUG
    update_event_average('event_feedbacks', 'average_feedback')
    enable_event_callbacks(EventFeedback)
  end

  def import_event_attachments
    event_attachments = @barf.select_all('SELECT * FROM event_attachment')
    puts "[ ] importing #{event_attachments.count} event attachments" if DEBUG
    event_attachments.each do |event_attachment|
      attachment_file = attachment_to_file(event_attachment)
      title = event_attachment['title'] || event_attachment['attachment_type']
      EventAttachment.create!(
        title: title,
        event_id: mappings(:events)[event_attachment['event_id']],
        public: penta_bool(event_attachment['public']),
        attachment_file_name: event_attachment['filename'],
        attachment_content_type: event_attachment['mime_type'],
        attachment_file_size: attachment_file.size,
        attachment: attachment_file
      )
      remove_file(attachment_file)
    end
  end

  def import_event_people
    EventPerson.skip_callback(:save, :after, :update_speaker_count)
    event_people = @barf.select_all('SELECT * FROM event_person')
    puts "[ ] importing #{event_people.count} event people" if DEBUG
    event_people.each do |event_person|
      EventPerson.create!(
        event_id: mappings(:events)[event_person['event_id']],
        person_id: mappings(:people)[event_person['person_id']],
        event_role: event_person['event_role'],
        role_state: event_person['event_role_state'],
        comment: event_person['remark']
      )
    end
    # update all event counts
    # Event.all.each do |event|
    #  c = EventPerson.where(event_id: event.id, event_role: :speaker).count
    #  event.update_attribute :speaker_count, c
    # end
    puts '[ ] updating speaker counters on events' if DEBUG
    ActiveRecord::Base.connection.execute("UPDATE events SET speaker_count=(SELECT count(*) FROM event_people WHERE events.id=event_people.event_id AND event_people.event_role='speaker')")
    # re-enable callback
    EventPerson.set_callback(:save, :after, :update_speaker_count)
  end

  private

  # because there is a mismatch between pentabarf text and frab string columns
  def truncate_string(str)
    return if str.nil?
    str[0..254]
  end

  def guess_public_name(person)
    # by order of preference
    if person['nickname']
      return person['nickname']
    elsif person['public_name']
      return person['public_name']
    elsif person['first_name'] and person['last_name']
      return "#{person['first_name']} #{person['last_name']}"
    elsif person['first_name']
      return person['first_name']
    elsif person['last_name']
      return person['last_name']
    else
      return 'unknown'
    end
  end

  def guess_gender(person)
    # pentabarf mostly encodes gender as a boolean
    if person['gender'].nil?
      return
    else
      return penta_bool(person['gender']) ? 'male' : 'female'
    end
  end

  def penta_bool(value)
    return false if value.nil?
    value == 't' ? true : false
  end

  def interval_to_minutes(interval)
    return nil unless interval
    hours, minutes, seconds = interval.split(':')
    hours.to_i * 60 + minutes.to_i
  end

  def start_time(day, interval)
    return nil unless day and interval
    t = Time.parse(day + ' ' + interval).in_time_zone
    if t.dst?
      # t + 2.hour
      t + 4.hour
    else
      # t + 3.hour
      t + 4.hour
    end
  end

  def image_to_file(image, id_column)
    if image and image['image'].size > 10
      file_name = "tmp/#{image[id_column]}.#{FILE_TYPES[image['mime_type']]}"
      File.open(file_name, 'w:ASCII-8BIT') { |f| f.write(image['image']) }

      # maybe convert the file?
      if image['mime_type'] == 'image/pjpeg' or image['mime_type'] == 'image/tiff'
        new_file_name = "tmp/#{image[id_column]}.png"
        system('convert', file_name, new_file_name)
        file_name = new_file_name
      end

      file = File.open(file_name, 'r')
      return file
    end
    nil
  end

  def attachment_to_file(attachment)
    if attachment
      # fix file name, maybe
      unless attachment['filename']
        puts "!!! had to guess attachment file name: #{attachment['event_attachment_id']} (#{attachment['filename']})"
        attachment['filename'] = attachment['attachment_type']
      end
      file_name = File.join('tmp', attachment['filename'])
      File.open(file_name, 'w:ASCII-8BIT') { |f| f.write(attachment['data']) }
      file = File.open(file_name, 'r')
      return file
    end
    nil
  end

  def remove_file(file)
    return unless file
    file.close
    File.unlink(file.path)
  end

  def mappings(name)
    @mappings = {} unless @mappings
    if !@mappings[name] and File.exist?(mappings_file(name))
      @mappings[name] = YAML.load_file(mappings_file(name))
    elsif !@mappings[name]
      fail "No mappings (#{name}) to load. Please run a full import."
    end
    return @mappings[name] if @mappings[name]
  end

  def create_mappings(name)
    @mappings = {} unless @mappings
    @mappings[name] = {}
  end

  def save_mappings(name)
    return unless @mappings and @mappings[name]
    File.open(mappings_file(name), 'w') { |f| YAML.dump(@mappings[name], f) }
  end

  def mappings_file(name)
    Rails.root.join('tmp', "#{name}_mappings.yml").to_s
  end

  def update_event_average(table, field)
    # FIXME speed problems: 26h
    # Event.joins(:event_feedbacks).readonly(false).all.each {|e| e.recalculate_average_feedback!}

    # direct sqlite syntax: 10min?
    ActiveRecord::Base.connection.execute "UPDATE events SET #{field}=(
       SELECT sum(rating)/count(rating)
       FROM #{table} WHERE events.id = #{table}.event_id)"

    # other databases?
    # UPDATE events
    #   SET average_feedback=(sum(rating)/count(rating))
    #   FROM events
    #   INNER JOIN event_feedbacks
    #   ON id = event_id
  end

  def disable_event_callback(average)
    # we wan't to update this in batch after all the inserts
    Event.skip_callback(:save, :after, :update_conflicts)
    average.skip_callback(:save, :after, :update_average)
    # TODO disable counter_cache?
  end

  def enable_event_callbacks(average)
    # re-enable after_save callbacks
    Event.set_callback(:save, :after, :update_conflicts)
    average.set_callback(:save, :after, :update_average)
  end
end

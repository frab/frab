namespace :frab do
  desc 'add fake conferences for testing'
  task add_fake_conferences: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      11.times do
        name = Faker::Superhero.name
        conference = Conference.create!(title: "#{name} Conference",
                                        acronym: name.parameterize,
                                        email: Faker::Internet.email,
                                        color: Faker::Color.hex_color[1..6])

        # Attach conference logo
        logo_path = Rails.root.join('app/assets/images/logo.png')
        if File.exist?(logo_path)
          conference.logo = File.open(logo_path)
          conference.save!
        end

        if rand(10) < 5
          conference.bcc_address = Faker::Internet.email
        end

        date = Faker::Time.forward(days: 23).beginning_of_day + 9.hours

        3.times do
          conference.languages << Language.create(code: %w(en de es pt-BR).sample)
        end

        rand(4).times do
          conference.review_metrics_attributes = [ { name: Faker::Company.buzzword } ]
        end

        4.times do
          day = Day.create!(conference: conference,
                            start_date: date,
                            end_date: date + 9.hours)

          Person.all.each do |person|
            next if rand(10) < 2

            Availability.create!(person: person,
                                 conference: conference,
                                 day: day,
                                 start_date: day.start_date + rand(4).hours,
                                 end_date: day.end_date - rand(4).hours)
          end

          conference.days << day
          date += 1.day
        end

        5.times do
          conference.rooms << Room.create!(conference: conference,
                                           name: Faker::App.name,
                                           size: Faker::Number.between(from: 1, to: 50) * 25,
                                           rank: Faker::Number.between(from: 1, to: 10))
        end

        10.times do
          name = Faker::Hacker.adjective
          t = conference.tracks.where(name: name)
          unless t.present?
            conference.tracks << Track.create!(conference: conference,
                                               name: name,
                                               color: Faker::Color.hex_color[1..6])
          end
        end

        50.times do
          event = Event.create!(conference: conference,
                                event_type: conference.allowed_event_types_as_list.sample,
                                state: %w(new review withdrawn unconfirmed confirmed canceled rejected).sample,
                                title: Faker::Book.title,
                                subtitle: Faker::Hacker.say_something_smart.chomp('!'),
                                abstract: Faker::Hipster.paragraph,
                                description: Faker::Hipster.paragraph,
                                time_slots: rand(10),
                                track: conference.tracks.all.sample,
                                language: conference.languages.all.sample.code,
                                public: Faker::Boolean.boolean,
                                do_not_record: Faker::Boolean.boolean,
                                tech_rider: Faker::Hipster.words.join(', '))

          5.times do
            EventPerson.create!(person: Person.all.sample,
                                event: event,
                                event_role: EventPerson::ROLES.sample,
                                role_state: EventPerson::STATES.sample,
                                comment: Faker::Lorem.sentence)
          end

          event.event_people.where(event_role: :coordinator).map(&:person).each do |person|
            event_rating = EventRating.create!(event: event,
                                               person: person,
                                               rating: (0..5).step(0.5).to_a.sample,
                                               comment: Faker::Lorem.sentence)
            conference.review_metrics.each do |review_metric|
              ReviewScore.create!(event_rating: event_rating,
                                  review_metric: review_metric,
                                  score: rand(6))
            end
          end
        end

        puts "Created conference #{conference.title} (#{conference.acronym}) with #{conference.tracks.count} tracks, #{conference.days.count} days, #{conference.events.count} events, #{conference.review_metrics.count} review metrics."
      end
    end
  end

  desc 'add fake persons for testing'
  task add_fake_persons: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      100.times do
        fakeperson = Faker::Omniauth.facebook
        p = Person.create!(email: fakeperson[:info][:email],
                           first_name: fakeperson[:info][:first_name],
                           last_name: fakeperson[:info][:last_name],
                           public_name: fakeperson[:extra][:raw_info][:username],
                           include_in_mailings: Faker::Boolean.boolean,
                           gender: [fakeperson[:extra][:raw_info][:gender], nil].sample)
        puts "Created person #{p.first_name} #{p.last_name} <#{p.email}> (#{p.public_name})"
      end
    end
  end

  desc 'create a fully planned conference with scheduled public events'
  task add_planned_conference: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      puts "Creating fully planned conference..."

      # Create conference
      conference = Conference.create!(
        title: "FrabCon 2024",
        acronym: "frabcon2024",
        email: "info@frabcon.example.com",
        color: "3f51b5",
        schedule_public: true,
        timezone: "Europe/Berlin",
        timeslot_duration: 15, # 15 minute slots
        default_timeslots: 4,  # 1 hour default event length
        feedback_enabled: true,
        schedule_html_intro: "<p>Welcome to FrabCon 2024! A fully planned conference for testing the scheduling system.</p>"
      )

      # Attach conference logo
      logo_path = Rails.root.join('app/assets/images/logo.png')
      if File.exist?(logo_path)
        conference.logo = File.open(logo_path)
        conference.save!
        puts "📷 Attached conference logo"
      else
        puts "⚠️  Logo file not found at #{logo_path}"
      end

      # Add languages
      %w(en de es).each do |lang_code|
        conference.languages << Language.find_or_create_by(code: lang_code)
      end

      # Create conference days (3-day conference)
      start_date = 1.month.from_now.beginning_of_day
      3.times do |day_index|
        day_date = start_date + day_index.days
        day = Day.create!(
          conference: conference,
          start_date: day_date + 9.hours,   # Start at 9 AM
          end_date: day_date + 18.hours     # End at 6 PM
        )
        conference.days << day
      end

      # Create rooms
      rooms_data = [
        { name: "Main Hall", size: 500, rank: 1 },
        { name: "Workshop Room A", size: 100, rank: 2 },
        { name: "Workshop Room B", size: 100, rank: 3 },
        { name: "Lightning Talk Stage", size: 200, rank: 4 }
      ]

      rooms_data.each do |room_data|
        conference.rooms << Room.create!(
          conference: conference,
          **room_data
        )
      end

      # Create tracks
      tracks_data = [
        { name: "Keynotes", color: "e91e63" },
        { name: "Web Development", color: "2196f3" },
        { name: "DevOps", color: "4caf50" },
        { name: "Security", color: "ff5722" },
        { name: "Lightning Talks", color: "ff9800" }
      ]

      tracks_data.each do |track_data|
        conference.tracks << Track.create!(
          conference: conference,
          **track_data
        )
      end

      # Create speakers (persons)
      speakers = []
      20.times do
        speaker = Person.create!(
          email: Faker::Internet.email,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          public_name: Faker::Internet.username,
          abstract: Faker::Lorem.paragraph(sentence_count: 3),
          description: Faker::Lorem.paragraph(sentence_count: 5),
          include_in_mailings: true,
          gender: %w(male female other).sample
        )
        speakers << speaker

        # Add availability for all conference days
        conference.days.each do |day|
          Availability.create!(
            person: speaker,
            conference: conference,
            day: day,
            start_date: day.start_date,
            end_date: day.end_date
          )
        end
      end

      # Create scheduled events with realistic conference program
      events_schedule = [
        # Day 1
        { day: 0, time: 9*60,   duration: 60,  track: "Keynotes",        room: "Main Hall",           title: "Opening Keynote: The Future of Open Source" },
        { day: 0, time: 10*60,  duration: 45,  track: "Web Development", room: "Workshop Room A",     title: "Modern JavaScript Frameworks Comparison" },
        { day: 0, time: 10*60,  duration: 45,  track: "DevOps",         room: "Workshop Room B",     title: "Container Orchestration with Kubernetes" },
        { day: 0, time: 11*60,  duration: 45,  track: "Security",       room: "Workshop Room A",     title: "Web Application Security Best Practices" },
        { day: 0, time: 11*60,  duration: 45,  track: "Web Development", room: "Workshop Room B",     title: "Progressive Web Apps Workshop" },
        { day: 0, time: 14*60,  duration: 30,  track: "Lightning Talks", room: "Lightning Talk Stage", title: "Quick Tips: Git Workflows" },
        { day: 0, time: 14*60+30, duration: 30, track: "Lightning Talks", room: "Lightning Talk Stage", title: "5 Minute Intro to Rust" },
        { day: 0, time: 15*60,  duration: 45,  track: "DevOps",         room: "Main Hall",           title: "Infrastructure as Code with Terraform" },
        { day: 0, time: 16*60,  duration: 45,  track: "Web Development", room: "Workshop Room A",     title: "Building APIs with GraphQL" },

        # Day 2
        { day: 1, time: 9*60,   duration: 60,  track: "Keynotes",        room: "Main Hall",           title: "Keynote: Building Inclusive Tech Communities" },
        { day: 1, time: 10*60,  duration: 45,  track: "Security",       room: "Workshop Room A",     title: "Zero Trust Security Architecture" },
        { day: 1, time: 10*60,  duration: 45,  track: "DevOps",         room: "Workshop Room B",     title: "CI/CD Pipeline Best Practices" },
        { day: 1, time: 11*60,  duration: 45,  track: "Web Development", room: "Workshop Room A",     title: "React Server Components Deep Dive" },
        { day: 1, time: 11*60,  duration: 45,  track: "Security",       room: "Workshop Room B",     title: "Secure Coding Workshop" },
        { day: 1, time: 14*60,  duration: 30,  track: "Lightning Talks", room: "Lightning Talk Stage", title: "Docker Tips and Tricks" },
        { day: 1, time: 14*60+30, duration: 30, track: "Lightning Talks", room: "Lightning Talk Stage", title: "CSS Grid Layout in 5 Minutes" },
        { day: 1, time: 15*60,  duration: 45,  track: "DevOps",         room: "Main Hall",           title: "Monitoring and Observability" },
        { day: 1, time: 16*60,  duration: 45,  track: "Security",       room: "Workshop Room A",     title: "Penetration Testing Fundamentals" },

        # Day 3
        { day: 2, time: 9*60,   duration: 60,  track: "Keynotes",        room: "Main Hall",           title: "Closing Keynote: What's Next in Tech" },
        { day: 2, time: 10*60,  duration: 45,  track: "Web Development", room: "Workshop Room A",     title: "WebAssembly: The Future of Web Performance" },
        { day: 2, time: 10*60,  duration: 45,  track: "DevOps",         room: "Workshop Room B",     title: "Service Mesh with Istio" },
        { day: 2, time: 11*60,  duration: 45,  track: "Security",       room: "Workshop Room A",     title: "Cloud Security Best Practices" },
        { day: 2, time: 11*60,  duration: 45,  track: "Web Development", room: "Workshop Room B",     title: "Advanced TypeScript Patterns" },
        { day: 2, time: 14*60,  duration: 30,  track: "Lightning Talks", room: "Lightning Talk Stage", title: "Database Migration Strategies" },
        { day: 2, time: 14*60+30, duration: 30, track: "Lightning Talks", room: "Lightning Talk Stage", title: "Open Source Project Management" },
        { day: 2, time: 15*60,  duration: 60,  track: "Keynotes",       room: "Main Hall",           title: "Panel: The Future of Remote Work in Tech" }
      ]

      events_schedule.each_with_index do |event_data, index|
        day = conference.days[event_data[:day]]
        track = conference.tracks.find_by(name: event_data[:track])
        room = conference.rooms.find_by(name: event_data[:room])

        # Calculate start time
        day_start = day.start_date
        event_start_time = day_start.beginning_of_day + event_data[:time].minutes

        # Create event
        event = Event.create!(
          conference: conference,
          event_type: event_data[:track] == "Lightning Talks" ? "lightning_talk" :
                     event_data[:track] == "Keynotes" ? "lecture" : "workshop",
          state: "scheduled",  # Fully scheduled state
          title: event_data[:title],
          subtitle: Faker::Company.catch_phrase,
          abstract: Faker::Lorem.paragraph(sentence_count: 4),
          description: Faker::Lorem.paragraph(sentence_count: 8),
          time_slots: event_data[:duration] / 15,  # Convert minutes to 15-minute slots
          track: track,
          room: room,
          start_time: event_start_time,
          language: %w(en de es).sample,
          public: true,  # Make sure it appears in public schedule
          do_not_record: [true, false].sample
        )

        # Assign 1-3 speakers to each event
        speaker_count = event_data[:track] == "Lightning Talks" ? 1 : rand(1..3)
        selected_speakers = speakers.sample(speaker_count)

        selected_speakers.each_with_index do |speaker, speaker_index|
          EventPerson.create!(
            person: speaker,
            event: event,
            event_role: speaker_index == 0 ? "speaker" : "cospeaker",
            role_state: "confirmed"
          )
        end
      end

      puts "✅ Created planned conference: #{conference.title} (#{conference.acronym})"
      puts "📅 Days: #{conference.days.count}"
      puts "🏢 Rooms: #{conference.rooms.count}"
      puts "🎯 Tracks: #{conference.tracks.count}"
      puts "🎤 Events: #{conference.events.count}"
      puts "👥 Speakers: #{speakers.count}"
      puts "📊 Scheduled public events: #{conference.events.scheduled.is_public.count}"
      puts ""
      puts "🌐 Access at: /#{conference.acronym}/public/schedule"
      puts "🛠️  Admin at: /#{conference.acronym}"
    end
  end

  desc 'add fake people, confernces, events, tracks, days etc'
  task add_fake_data: [:add_fake_persons, :add_fake_conferences, :add_planned_conference]
end

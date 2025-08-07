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

  desc 'create a multilingual conference with German and English translations'
  task add_multilingual_conference: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      puts "Creating multilingual conference with German and English translations..."

      # Create conference
      conference = Conference.create!(
        title: "EuroTech Conference 2024",
        acronym: "eurotech2024",
        email: "info@eurotech.example.com",
        color: "4caf50",
        schedule_public: true,
        timezone: "Europe/Berlin",
        timeslot_duration: 15,
        default_timeslots: 4,
        feedback_enabled: true,
        schedule_html_intro: "<p>Welcome to EuroTech Conference 2024! Ein mehrsprachiges Event für Technologie-Enthusiasten.</p>"
      )

      # Add German and English languages
      %w(de en).each do |lang_code|
        conference.languages << Language.find_or_create_by(code: lang_code)
      end

      # Create conference days (2-day conference)
      start_date = 2.months.from_now.beginning_of_day
      2.times do |day_index|
        day_date = start_date + day_index.days
        day = Day.create!(
          conference: conference,
          start_date: day_date + 9.hours,
          end_date: day_date + 18.hours
        )
        conference.days << day
      end

      # Create rooms
      rooms_data = [
        { name: "Hauptsaal", size: 400, rank: 1 },
        { name: "Workshop Raum A", size: 80, rank: 2 },
        { name: "Workshop Raum B", size: 80, rank: 3 }
      ]

      rooms_data.each do |room_data|
        conference.rooms << Room.create!(
          conference: conference,
          **room_data
        )
      end

      # Create multilingual tracks
      tracks_data = [
        { name_de: "Hauptvorträge", name_en: "Keynotes", color: "e91e63" },
        { name_de: "Web-Entwicklung", name_en: "Web Development", color: "2196f3" },
        { name_de: "Künstliche Intelligenz", name_en: "Artificial Intelligence", color: "9c27b0" },
        { name_de: "DevOps & Cloud", name_en: "DevOps & Cloud", color: "4caf50" }
      ]

      tracks_data.each do |track_data|
        track = Track.create!(
          conference: conference,
          name: track_data[:name_en],  # Set default name first
          color: track_data[:color]
        )

        # Set German and English names using Mobility
        I18n.with_locale(:de) { track.name = track_data[:name_de] }
        I18n.with_locale(:en) { track.name = track_data[:name_en] }
        track.save!

        conference.tracks << track
      end

      # Create speakers
      speakers = []
      15.times do
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

      # Create multilingual events
      multilingual_events = [
        # Day 1 - Keynotes
        {
          day: 0, time: 9*60, duration: 60, track: "Hauptvorträge", room: "Hauptsaal",
          title_de: "Eröffnungskeynote: Die Zukunft der Technologie",
          title_en: "Opening Keynote: The Future of Technology",
          subtitle_de: "Ein Blick in die nächsten 10 Jahre",
          subtitle_en: "A Look into the Next 10 Years",
          abstract_de: "Diese Keynote bietet einen umfassenden Überblick über die technologischen Trends, die unsere Zukunft prägen werden.",
          abstract_en: "This keynote provides a comprehensive overview of the technological trends that will shape our future.",
          description_de: "In diesem Vortrag werden wir die wichtigsten technologischen Entwicklungen der letzten Jahre analysieren und einen Ausblick auf die kommenden Innovationen geben. Wir betrachten Bereiche wie künstliche Intelligenz, Quantencomputing, nachhaltige Technologien und die Auswirkungen auf die Gesellschaft.",
          description_en: "In this presentation, we will analyze the most important technological developments of recent years and provide an outlook on upcoming innovations. We will examine areas such as artificial intelligence, quantum computing, sustainable technologies, and their impact on society."
        },

        # Day 1 - Web Development
        {
          day: 0, time: 10*60, duration: 45, track: "Web-Entwicklung", room: "Workshop Raum A",
          title_de: "Moderne JavaScript Frameworks im Vergleich",
          title_en: "Modern JavaScript Frameworks Comparison",
          subtitle_de: "React, Vue, Angular und die neuen Player",
          subtitle_en: "React, Vue, Angular and the New Players",
          abstract_de: "Ein detaillierter Vergleich der beliebtesten JavaScript Frameworks mit praktischen Beispielen.",
          abstract_en: "A detailed comparison of the most popular JavaScript frameworks with practical examples.",
          description_de: "Dieser Workshop bietet eine umfassende Analyse der aktuellen JavaScript Framework-Landschaft. Wir werden die Stärken und Schwächen von React, Vue.js, Angular und anderen aufkommenden Frameworks untersuchen. Praktische Code-Beispiele zeigen die Unterschiede in der Entwicklungsphilosophie und Performance.",
          description_en: "This workshop provides a comprehensive analysis of the current JavaScript framework landscape. We will examine the strengths and weaknesses of React, Vue.js, Angular, and other emerging frameworks. Practical code examples demonstrate the differences in development philosophy and performance."
        },

        # Day 1 - AI
        {
          day: 0, time: 11*60, duration: 45, track: "Künstliche Intelligenz", room: "Workshop Raum B",
          title_de: "Einführung in Machine Learning mit Python",
          title_en: "Introduction to Machine Learning with Python",
          subtitle_de: "Von den Grundlagen zur praktischen Anwendung",
          subtitle_en: "From Basics to Practical Application",
          abstract_de: "Ein hands-on Workshop für Einsteiger in das Thema Machine Learning.",
          abstract_en: "A hands-on workshop for beginners in machine learning.",
          description_de: "In diesem praktischen Workshop lernen die Teilnehmer die Grundlagen des Machine Learning kennen. Wir verwenden Python und beliebte Bibliotheken wie scikit-learn und pandas, um einfache ML-Modelle zu erstellen. Von der Datenaufbereitung bis zur Modellbewertung werden alle wichtigen Schritte behandelt.",
          description_en: "In this practical workshop, participants will learn the fundamentals of machine learning. We use Python and popular libraries like scikit-learn and pandas to create simple ML models. From data preparation to model evaluation, all important steps are covered."
        },

        # Day 2 - DevOps
        {
          day: 1, time: 9*60, duration: 60, track: "DevOps & Cloud", room: "Hauptsaal",
          title_de: "Container-Orchestrierung mit Kubernetes",
          title_en: "Container Orchestration with Kubernetes",
          subtitle_de: "Skalierbare Anwendungen in der Cloud",
          subtitle_en: "Scalable Applications in the Cloud",
          abstract_de: "Lernen Sie, wie Sie Kubernetes für die Bereitstellung und Verwaltung von Container-Anwendungen nutzen.",
          abstract_en: "Learn how to use Kubernetes for deploying and managing containerized applications.",
          description_de: "Kubernetes hat sich als Standard für die Container-Orchestrierung etabliert. In diesem Vortrag erkunden wir die Kernkonzepte von Kubernetes, einschließlich Pods, Services, Deployments und ConfigMaps. Wir zeigen, wie Sie Ihre Anwendungen skalierbar und zuverlässig in einer Kubernetes-Umgebung bereitstellen können.",
          description_en: "Kubernetes has established itself as the standard for container orchestration. In this presentation, we explore the core concepts of Kubernetes, including Pods, Services, Deployments, and ConfigMaps. We show how you can deploy your applications scalably and reliably in a Kubernetes environment."
        },

        # Day 2 - Web Development
        {
          day: 1, time: 10*60, duration: 45, track: "Web-Entwicklung", room: "Workshop Raum A",
          title_de: "Progressive Web Apps Workshop",
          title_en: "Progressive Web Apps Workshop",
          subtitle_de: "Native App-Erlebnis im Browser",
          subtitle_en: "Native App Experience in the Browser",
          abstract_de: "Erstellen Sie Web-Anwendungen, die sich wie native Apps verhalten.",
          abstract_en: "Create web applications that behave like native apps.",
          description_de: "Progressive Web Apps (PWAs) kombinieren das Beste aus Web- und mobilen Anwendungen. In diesem Workshop lernen Sie, wie Sie Service Workers, Web App Manifeste und andere PWA-Technologien einsetzen, um offline-fähige, installierbare Webanwendungen zu erstellen, die auf allen Geräten funktionieren.",
          description_en: "Progressive Web Apps (PWAs) combine the best of web and mobile applications. In this workshop, you'll learn how to use Service Workers, Web App Manifests, and other PWA technologies to create offline-capable, installable web applications that work on all devices."
        }
      ]

      multilingual_events.each_with_index do |event_data, index|
        day = conference.days[event_data[:day]]
        track = conference.tracks.find { |t| I18n.with_locale(:de) { t.name == event_data[:track] } }
        room = conference.rooms.find_by(name: event_data[:room])

        # Calculate start time
        day_start = day.start_date
        event_start_time = day_start.beginning_of_day + event_data[:time].minutes

        # Create event with default English title
        event = Event.create!(
          conference: conference,
          event_type: event_data[:track] == "Hauptvorträge" ? "lecture" : "workshop",
          state: "scheduled",
          title: event_data[:title_en],  # Set default title first
          time_slots: event_data[:duration] / 15,
          track: track,
          room: room,
          start_time: event_start_time,
          language: %w(de en).sample,
          public: true,
          do_not_record: false
        )

        # Set multilingual content using Mobility
        I18n.with_locale(:de) do
          event.title = event_data[:title_de]
          event.subtitle = event_data[:subtitle_de]
          event.abstract = event_data[:abstract_de]
          event.description = event_data[:description_de]
        end

        I18n.with_locale(:en) do
          event.title = event_data[:title_en]
          event.subtitle = event_data[:subtitle_en]
          event.abstract = event_data[:abstract_en]
          event.description = event_data[:description_en]
        end

        event.save!

        # Assign speakers
        speaker_count = event_data[:track] == "Hauptvorträge" ? 1 : rand(1..2)
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

      puts "✅ Created multilingual conference: #{conference.title} (#{conference.acronym})"
      puts "🌍 Languages: #{conference.languages.map(&:code).join(', ')}"
      puts "📅 Days: #{conference.days.count}"
      puts "🏢 Rooms: #{conference.rooms.count}"
      puts "🎯 Tracks: #{conference.tracks.count}"
      puts "🎤 Events: #{conference.events.count}"
      puts "👥 Speakers: #{speakers.count}"
      puts ""
      puts "🌐 Access at: /#{conference.acronym}/public/schedule"
      puts "🛠️  Admin at: /#{conference.acronym}"
      puts ""
      puts "🔤 Test translations by switching languages in the interface"
    end
  end

  desc 'add fake people, confernces, events, tracks, days etc'
  task add_fake_data: [:add_fake_persons, :add_fake_conferences, :add_planned_conference, :add_multilingual_conference]
end

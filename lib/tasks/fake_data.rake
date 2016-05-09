namespace :frab do
  desc 'add fake tracks for testing'
  task add_fake_tracks: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      conference = Conference.all.shuffle.first
      if not conference.present?
        puts 'No conference exists, no new tracks created'
      else
        5.times do
          name = Faker::Hacker.adjective
          t = conference.tracks.where(name: name)
          if not t.present?
            t = Track.create!(conference: conference,
                              name: name,
                              color: Faker::Color.hex_color[1..6])
            puts "Created track #{t.name}"
          end
        end
      end
    end
  end

  desc 'add fake persons for testing'
  task add_fake_persons: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      10.times do
        p = Person.create!(email: Faker::Internet.email,
                           first_name: Faker::Name.first_name,
                           last_name: Faker::Name.last_name,
                           public_name: Faker::Internet.user_name,
                           include_in_mailings: Faker::Boolean.boolean)
        puts "Created person #{p.first_name} #{p.last_name} <#{p.email}> (#{p.public_name})"
      end
    end
  end

  desc 'add fake events for testing'
  task add_fake_events: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      conference = Conference.all.shuffle.first
      if not conference.present?
        puts 'No conference exists, no new events created'
      else
        10.times do
          e = Event.create!(conference: conference,
                            event_type: Event::TYPES.shuffle.first,
                            title: Faker::Book.title,
                            subtitle: Faker::Hacker.say_something_smart.chomp('!'),
                            abstract: Faker::Hipster.paragraph,
                            description: Faker::Hipster.paragraph,
                            time_slots: rand(10),
                            track: Track.all.shuffle.first,
                            language: conference.languages.all.shuffle.first,
                            public: Faker::Boolean.boolean,
                            do_not_record: Faker::Boolean.boolean,
                            tech_rider: Faker::Hipster.words.join(", "))
          rand(5).times do
            ep = EventPerson.create!(person: Person.all.shuffle.first,
                                     event: e,
                                     event_role: EventPerson::ROLES.shuffle.first,
                                     role_state: EventPerson::STATES.shuffle.first,
                                     comment: Faker::Lorem.sentence)
          end

          puts "Created event #{e.title} (#{e.subtitle}), #{e.event_people.count} event people"
        end
      end
    end
  end

  desc 'add fake tracks, people and events'
  task add_fake_data: [ :add_fake_tracks, :add_fake_persons, :add_fake_events ]
end

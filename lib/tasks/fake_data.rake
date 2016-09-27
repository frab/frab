namespace :frab do

  desc 'add fake conferences for testing'
  task add_fake_conferences: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      10.times do
        name = Faker::Superhero.name
        conference = Conference.create!(title: "#{name} Conference",
                                        acronym: name.parameterize,
                                        email: Faker::Internet.email,
                                        color: Faker::Color.hex_color[1..6])

        date = Faker::Time.forward(23).beginning_of_day + 9.hours

        3.times do
          conference.languages << Language.create(code: %w(en de es pt-BR).shuffle.first)
        end

        4.times do
          day = Day.create!(start_date: date,
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
                                           size: Faker::Number.between(1, 50) * 25,
                                           rank: Faker::Number.between(1, 10))
        end

        10.times do
          name = Faker::Hacker.adjective
          t = conference.tracks.where(name: name)
          unless t.present?
            conference.tracks << Track.create!(name: name,
                                               color: Faker::Color.hex_color[1..6])
          end
        end

        50.times do
          event = Event.create!(conference: conference,
                                event_type: Event::TYPES.shuffle.first,
                                state: %w(new review withdrawn unconfirmed confirmed canceled rejected).shuffle.first,
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

          5.times do
            EventPerson.create!(person: Person.all.shuffle.first,
                                event: event,
                                event_role: EventPerson::ROLES.shuffle.first,
                                role_state: EventPerson::STATES.shuffle.first,
                                comment: Faker::Lorem.sentence)
          end
        end

        puts "Created conference #{conference.title} (#{conference.acronym}) with #{conference.tracks.count} tracks, #{conference.days.count} days, #{conference.events.count} events"
      end
    end
  end

  desc 'add fake persons for testing'
  task add_fake_persons: :environment do |_t, _args|
    ActiveRecord::Base.transaction do
      100.times do
        p = Person.create!(email: Faker::Internet.email,
                           first_name: Faker::Name.first_name,
                           last_name: Faker::Name.last_name,
                           public_name: Faker::Internet.user_name,
                           include_in_mailings: Faker::Boolean.boolean,
                           gender: ["male", "female", nil].shuffle.first)
        puts "Created person #{p.first_name} #{p.last_name} <#{p.email}> (#{p.public_name})"
      end
    end
  end

  desc 'add fake people, confernces, events, tracks, days etc'
  task add_fake_data: [ :add_fake_persons, :add_fake_conferences ]
end

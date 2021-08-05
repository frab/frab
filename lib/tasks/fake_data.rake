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

        if rand(10) < 8
          begin
            uri=URI("https://randomuser.me/api/?inc=picture&gender=#{fakeperson[:extra][:raw_info][:gender]}")
            response = Net::HTTP.get(uri)
            r=JSON.parse(response)
            imguri = URI(r['results'][0]['picture']['large'])
            p.update_attributes(avatar: StringIO.new(imguri.open.read))
          rescue StandardError => error
            puts "Ignoring: #$!"
          end
        end

        puts "Created person #{p.first_name} #{p.last_name} <#{p.email}> (#{p.public_name})"
      end
    end
  end

  desc 'add fake people, confernces, events, tracks, days etc'
  task add_fake_data: [:add_fake_persons, :add_fake_conferences]
end

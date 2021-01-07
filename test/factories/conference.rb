FactoryBot.define do
  sequence :conference_acronym do |n|
    "frabcon#{n}"
  end

  sequence :conference_title do |n|
    "FrabCon#{2000+n}"
  end

  trait :three_days do
    after :create do |conference|
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.since(1.day).since(11.hours),
                                      end_date: Date.today.since(1.day).since(23.hours))
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.since(2.days).since(10.hours),
                                      end_date: Date.today.since(2.days).since(24.hours))
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.since(3.days).since(10.hours),
                                      end_date: Date.today.since(3.days).since(17.hours))
    end
  end

  trait :past_three_days do
    after :create do |conference|
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.ago(1.week).since(11.hours),
                                      end_date: Date.today.ago(1.week).since(23.hours))
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.ago(2.weeks).since(10.hours),
                                      end_date: Date.today.ago(2.weeks).since(24.hours))
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.ago(3.weeks).since(10.hours),
                                      end_date: Date.today.ago(3.weeks).since(17.hours))
    end
  end

  trait :with_rooms do
    after :create do |conference|
      conference.rooms << create(:room, conference: conference)
    end
  end

  trait :with_events do
    after :create do |conference|
      conference.events << create(:event, conference: conference,
                                          room: conference.rooms.first,
                                          state: 'confirmed',
                                          public: true,
                                          start_time: Date.today.since(1.day).since(11.hours))
      conference.events << create(:event, conference: conference,
                                          room: conference.rooms.first,
                                          state: 'confirmed',
                                          public: true,
                                          start_time: Date.today.since(2.days).since(15.hours))
      conference.events << create(:event, conference: conference,
                                          room: conference.rooms.first,
                                          state: 'confirmed',
                                          public: true,
                                          start_time: Date.today.since(3.days).since(11.hours))
    end
  end

  trait :with_speakers do
    after :create do |conference|
      conference.events.each do |event|
        speaker = create(:person)
        create(:confirmed_speaker, event: event, person: speaker, conference: conference)
      end
    end
  end

  trait :with_review_metrics do
    after :create do |conference|
      2.times do
        review_metric = create(:review_metric, conference: conference)
        review_metric.save
      end
    end
  end


  trait :with_reviews do
    after :create do |conference|
      reviewer = create(:person)
      score = 1
      conference.events.each do |event|
        conference.review_metrics.each do |review_metric|
          event_rating = create(:event_rating, event: event, rating: score)
          create(:review_score, event_rating: event_rating, review_metric: review_metric, score: score)
          
          score += 1
          score = 1 if score > 5
        end
      end
    end
  end

  trait :with_parent_conference do
    after :create do |conference|
      unless conference.subs.any?
        conference.parent = create(:three_day_conference_with_events, title: "#{conference.title} parent")
      end
    end
  end

  trait :with_sub_conference do
    after :create do |conference|
      if conference.main_conference?
        create(:conference, parent: conference)
      end
    end
  end

  factory :conference do
    title { generate(:conference_title) }
    acronym { generate(:conference_acronym) }
    timeslot_duration { 15 }
    default_timeslots { 4 }
    max_timeslots { 20 }
    allowed_event_timeslots_csv { '3,4' }
    feedback_enabled { true }
    expenses_enabled { true }
    transport_needs_enabled { true }
    schedule_public { true }
    timezone { 'Berlin' }
    parent { nil }

    factory :three_day_conference, traits: [:three_days, :with_sub_conference]
    factory :three_day_conference_with_events, traits: [:three_days, :with_rooms, :with_events, :with_sub_conference]
    factory :three_day_conference_with_events_and_speakers, traits: [:three_days, :with_rooms, :with_events, :with_sub_conference, :with_speakers]
    factory :three_day_conference_with_review_metrics_and_events, traits: [:three_days, :with_rooms, :with_events, :with_review_metrics]
    factory :three_day_conference_with_review_metrics_and_events_and_reviews, traits: [:three_days, :with_rooms, :with_events, :with_review_metrics, :with_reviews]
    factory :three_day_conference_with_review_metrics_and_events_and_speakers, traits: [:three_days, :with_rooms, :with_events, :with_review_metrics, :with_sub_conference, :with_speakers]
    factory :sub_conference_with_events, traits: [:with_rooms, :with_events, :with_parent_conference]
    factory :past_days_conference, traits: [:past_three_days]
  end
end

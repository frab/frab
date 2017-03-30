FactoryGirl.define do
  sequence :conference_acronym do |n|
    "frabcon#{n}"
  end

  trait :three_days do
    after :create do |conference|
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.since(1.days).since(11.hours),
                                      end_date: Date.today.since(1.days).since(23.hours))
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.since(2.days).since(10.hours),
                                      end_date: Date.today.since(2.days).since(24.hours))
      conference.days << create(:day, conference: conference,
                                      start_date: Date.today.since(3.days).since(10.hours),
                                      end_date: Date.today.since(3.days).since(17.hours))
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
                                          start_time: Date.today.since(1.days).since(11.hours))
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
        create(:conference, parent: conference, title: "#{conference.title} sub")
      end
    end
  end

  factory :conference do
    title 'FrabCon'
    acronym { generate(:conference_acronym) }
    timeslot_duration 15
    default_timeslots 4
    max_timeslots 20
    feedback_enabled true
    expenses_enabled true
    transport_needs_enabled true
    schedule_public true
    timezone 'Berlin'
    parent nil

    factory :three_day_conference, traits: [:three_days, :with_sub_conference]
    factory :three_day_conference_with_events, traits: [:three_days, :with_rooms, :with_events, :with_sub_conference]
    factory :three_day_conference_with_events_and_speakers, traits: [:three_days, :with_rooms, :with_events, :with_sub_conference, :with_speakers]
    factory :sub_conference_with_events, traits: [:with_rooms, :with_events, :with_parent_conference]
  end
end

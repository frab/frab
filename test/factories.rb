FactoryGirl.define do
  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :conference_acronym do |n|
    "frabcon#{n}"
  end

  sequence :room_names do |n|
    "Room #{n}"
  end

  sequence :event_title do |n|
    "Introducing frap part #{n}"
  end

  trait :admin_role do
    role 'admin'
  end

  trait :crew_role do
    role 'crew'
  end

  trait :conference_orga_role do
    role 'orga'
  end

  trait :conference_coordinator_role do
    role 'coordinator'
  end

  trait :conference_reviewer_role do
    role 'reviewer'
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

  trait :with_parent_conference do
    after :create do |conference|
      unless conference.subs.any?
        conference.parent = create(:three_day_conference_with_events, title: "#{conference.title} parent")
      end
    end
  end

  trait :with_sub_conference do
    after :create do |conference|
      if conference.parent?
        create(:conference, parent: conference, title: "#{conference.title} sub")
      end
    end
  end

  factory :user do
    person
    email { generate(:email) }
    password 'frab23'
    password_confirmation { password }
    sign_in_count 0
    confirmed_at { Time.now }

    factory :admin_user, traits: [:admin_role]
    factory :crew_user, traits: [:crew_role]
  end

  factory :conference_user do
    conference
    after :build do |cu|
      user = build(:crew_user)
      user.conference_users << cu
      cu.user = user
    end

    factory :conference_orga, traits: [:conference_orga_role]
    factory :conference_coordinator, traits: [:conference_coordinator_role]
    factory :conference_reviewer, traits: [:conference_reviewer_role]
  end

  factory :conference_export do
    conference
    locale 'en'
    tarball { File.open(File.join(Rails.root, 'test', 'fixtures', 'tarball.tar.gz')) }
  end

  factory :person do
    email { generate(:email) }
    public_name 'Fred Besen'
  end

  factory :expense do
    name 'Kiste Bier'
    value 22.5
    person
    conference
  end

  factory :day do
    start_date { Date.today.since(1.days).since(11.hours) }
    end_date { Date.today.since(1.days).since(23.hours) }
  end

  factory :room do
    name { generate(:room_names) }
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
    factory :sub_conference_with_events, traits: [:with_rooms, :with_events, :with_parent_conference]
  end

  factory :call_for_participation do
    start_date { Date.today.ago(1.days) }
    end_date { Date.today.since(6.days) }
    conference
  end

  factory :notification do
    reject_body 'reject body text'
    reject_subject 'rejected subject'
    accept_body 'accept body text'
    accept_subject 'accepted subject'
    schedule_body 'schedule body text'
    schedule_subject 'schedule subject'
    locale 'en'
    conference
  end

  factory :availability do
    conference
    person
    day { conference.days.first }
    start_date { conference.days.first.start_date.since(2.hours) }
    end_date { conference.days.first.start_date.since(3.hours) }
  end

  factory :language do
    code 'EN'

    factory :english_language do
    end
    factory :german_language do
      code 'DE'
    end
  end

  factory :event do
    title { generate(:event_title) }
    subtitle 'Getting started organizing your conference'
    time_slots 4
    start_time '10:00'
    conference { create(:three_day_conference) }
  end

  factory :event_person do
    person
    event
    event_role 'speaker'

    factory :confirmed_event_person do
      role_state 'confirmed'
    end
  end

  factory :event_rating do
    event
    person
    rating 3.0
    comment 'blah'
  end

  factory :event_feedback do
    rating 3.0
    comment 'doh'
  end

  factory :ticket do
    event
    remote_ticket_id '1234'
  end

  factory :mail_template do
    conference
    name 'template one'
    subject 'subject one'
    content '|first_name #first_name| |last_name #last_name| |public_name #public_name|'
  end
end

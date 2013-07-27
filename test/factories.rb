FactoryGirl.define do
  
  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :conference_acronym do |n|
    "frabcon#{n}"
  end

  sequence :event_title do |n|
    "Introducing frap part #{n}"
  end

  trait :admin_role do
    role "admin"
  end

  trait :orga_role do
    role "orga"
  end

  trait :coordinator_role do
    role "coordinator"
  end

  trait :reviewer_role do
    role "reviewer"
  end

  trait :three_days do
    after_create do |conference|
      conference.days << FactoryGirl.create(:day, 
                                            start_date: Date.today.since(1.days).since(11.hours),
                                            end_date: Date.today.since(1.days).since(23.hours))
      conference.days << FactoryGirl.create(:day,
                                            start_date: Date.today.since(2.days).since(10.hours),
                                            end_date: Date.today.since(2.days).since(24.hours))
      conference.days << FactoryGirl.create(:day,
                                            start_date: Date.today.since(3.days).since(10.hours),
                                            end_date: Date.today.since(3.days).since(17.hours))
    end
  end

  factory :user do
    person
    email { Factory.next(:email) }
    password "frab23"
    password_confirmation { password }
    sign_in_count 0
    confirmed_at { Time.now }

    factory :admin_user, traits: [:admin_role]
    factory :orga_user, traits: [:orga_role]
    factory :coordinator_user, traits: [:coordinator_role]
    factory :reviewer_user, traits: [:reviewer_role]
  end

  factory :person do
    email { Factory.next(:email) }
    public_name "Fred Besen"
  end

  factory :day do
    start_date { Date.today.since(1.days).since(11.hours) }
    end_date { Date.today.since(1.days).since(23.hours) }
  end

  factory :conference do
    title "FrabCon"
    acronym { Factory.next(:conference_acronym) }
    timeslot_duration 15
    default_timeslots 4
    max_timeslots 20
    feedback_enabled true
    schedule_public true
    timezone "Berlin"

    factory :three_day_conference, traits: [:three_days]
  end

  factory :call_for_papers do
    start_date { Date.today.ago(1.days) }
    end_date { Date.today.since(6.days) }
    conference
  end

  factory :notification do
    reject_body "reject body text"
    reject_subject "rejected subject"
    accept_body "accept body text"
    accept_subject "accepted subject"
    locale "en"
    call_for_papers
  end

  factory :availability do
    conference
    person
    day { conference.days.first }
    start_date { conference.days.first.start_date.since(2.hours) }
    end_date { conference.days.first.start_date.since(3.hours) }
  end

  factory :language do
    code "EN"
    
    factory :english_language do
    end
    factory :german_language do
      code "DE"
    end
  end

  factory :event do
    title { Factory.next(:event_title) }
    subtitle "Getting started organizing your conference"
    time_slots 4
    start_time "10:00"
    conference { Factory.create(:three_day_conference) }
  end

  factory :event_person do
    person
    event 
    event_role "speaker"
  end

  factory :event_rating do
    event
    person
    rating 3.0
    comment "blah"
  end

  factory :event_feedback do
    rating 3.0
    comment "doh"
  end

  factory :ticket do
    event
    remote_ticket_id "1234"
  end

end


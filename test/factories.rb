FactoryGirl.define do
  sequence :email do |n|
    "test#{n}@example.com"
  end

  factory :availability do
    conference
    person
    day { conference.days.first }
    start_date { conference.days.first.start_date.since(2.hours) }
    end_date { conference.days.first.start_date.since(3.hours) }
  end

  factory :call_for_participation do
    start_date { Date.today.ago(1.day) }
    end_date { Date.today.since(6.days) }
    conference

    factory :past_call_for_participation do
      start_date Date.today.ago(100.days)
      end_date Date.today.ago(90.days)
    end
    factory :future_call_for_participation do
      start_date Date.today.since(100.days)
      end_date Date.today.since(90.days)
    end
  end

  factory :conference_export do
    conference
    locale 'en'
    tarball { File.open(File.join(Rails.root, 'test', 'fixtures', 'tarball.tar.gz')) }
  end

  factory :day do
    conference
    start_date { Date.today.since(1.day).since(11.hours) }
    end_date { Date.today.since(1.day).since(23.hours) }
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

  factory :expense do
    name 'Kiste Bier'
    value 22.5
    person
    conference
  end

  factory :mail_template do
    conference
    name 'template one'
    subject 'subject one'
    content '|first_name #first_name| |last_name #last_name| |public_name #public_name|'
  end
end

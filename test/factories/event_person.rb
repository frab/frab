FactoryGirl.define do
  factory :event_person do
    person
    event
    event_role 'speaker'

    factory :confirmed_event_person do
      role_state 'confirmed'
    end

    factory :confirmed_speaker do
      transient do
        conference nil
      end
      event_role 'speaker'
      role_state 'confirmed'

      after :create do |event_person, evaluator|
        evaluator.conference.days.each { |day|
          create(
            :availability,
            conference: evaluator.conference,
            person: event_person.person,
            start_date: day.start_date,
            end_date: day.end_date
          )
        }
      end
    end
  end
end

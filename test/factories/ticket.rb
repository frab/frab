FactoryGirl.define do
  factory :ticket do
    remote_ticket_id '1234'

    factory :event_ticket do
      association :object, factory: :event
    end

    factory :person_ticket do
      association :object, factory: :person
    end
  end
end

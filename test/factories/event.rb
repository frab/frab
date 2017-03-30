FactoryGirl.define do
  sequence :event_title do |n|
    "Introducing frap part #{n}"
  end

  factory :event do
    title { generate(:event_title) }
    subtitle 'Getting started organizing your conference'
    time_slots 4
    start_time '10:00'
    conference { create(:three_day_conference) }
  end
end

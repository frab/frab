FactoryGirl.define do
  sequence :room_names do |n|
    "Room #{n}"
  end

  factory :room do
    name { generate(:room_names) }
  end
end

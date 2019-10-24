FactoryBot.define do
  sequence :track_names do |n|
    "Track #{n}"
  end

  factory :track do
    name { generate(:track_names) }
  end
end

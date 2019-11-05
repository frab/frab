FactoryBot.define do
  sequence :classifier_name do |n|
    "Classifier #{n}"
  end
  factory :classifier do
    name { generate(:classifier_name) }
    description { "Info text on this classifier" }
  end
end

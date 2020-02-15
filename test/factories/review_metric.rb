FactoryBot.define do
  sequence :review_metric_name do |n|
    "Metric#{n}"
  end
  
  factory :review_metric do
    conference
    name { generate(:review_metric_name) }
    description { "The event seems highly ipsum lorem" }
  end
end

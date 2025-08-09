FactoryBot.define do
  factory :transport_need do
    person
    conference
    at { Date.today.since(1.day).since(10.hours) }
    transport_type { 'bus' }
    note { 'Transport note' }
  end
end

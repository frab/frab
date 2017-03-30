FactoryGirl.define do
  trait :admin_role do
    role 'admin'
  end

  trait :crew_role do
    role 'crew'
  end

  factory :user do
    person
    email { generate(:email) }
    password 'frab23'
    confirmed_at { Time.now }

    factory :admin_user, traits: [:admin_role]
    factory :crew_user, traits: [:crew_role]
  end
end

FactoryBot.define do
  trait :admin_role do
    role 'admin'
  end

  trait :crew_role do
    role 'crew'
  end

  trait :submitter_role do
    role 'submitter'
  end

  factory :user do
    person
    email { generate(:email) }
    password 'frab123'
    confirmed_at { Time.now }

    factory :admin_user, traits: [:admin_role]
    factory :crew_user, traits: [:crew_role]
    factory :cfp_user, traits: [:submitter_role]
  end
end

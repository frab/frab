FactoryGirl.define do
  trait :conference_orga_role do
    role 'orga'
  end

  trait :conference_coordinator_role do
    role 'coordinator'
  end

  trait :conference_reviewer_role do
    role 'reviewer'
  end

  factory :conference_user do
    conference
    after :build do |cu|
      user = build(:crew_user)
      user.conference_users << cu
      cu.user = user
    end

    factory :conference_orga, traits: [:conference_orga_role]
    factory :conference_coordinator, traits: [:conference_coordinator_role]
    factory :conference_reviewer, traits: [:conference_reviewer_role]
  end
end

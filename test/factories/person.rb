FactoryBot.define do
  sequence :person_public_name do |n|
    "Fred Besen #{n}"
  end

  factory :person do
    email { generate(:email) }
    public_name { generate(:person_public_name)  }
  end
end

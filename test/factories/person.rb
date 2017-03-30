FactoryGirl.define do
  factory :person do
    email { generate(:email) }
    public_name 'Fred Besen'
  end
end

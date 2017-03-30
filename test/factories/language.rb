FactoryGirl.define do
  factory :language do
    code 'EN'

    factory :english_language do
    end
    factory :german_language do
      code 'DE'
    end
  end
end

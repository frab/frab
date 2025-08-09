FactoryBot.define do
  factory :language do
    code { 'en' }

    factory :english_language do
    end
    factory :german_language do
      code { 'de' }
    end
  end
end

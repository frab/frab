FactoryGirl.define do
  factory :notification do
    reject_body 'reject body text'
    reject_subject 'rejected subject'
    accept_body 'accept body text'
    accept_subject 'accepted subject'
    schedule_body 'schedule body text'
    schedule_subject 'schedule subject'
    locale 'en'
    conference
  end
end

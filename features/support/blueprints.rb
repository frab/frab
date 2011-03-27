require 'machinist/active_record'

User.blueprint do
  email { "test#{sn}@example.org" }
  password { "frab23" }
  password_confirmation { object.password }
end

Person.blueprint do
  email { "test#{sn}@example.org" }
  first_name { "Fred" }
  last_name { "Besen" }
  gender { "male" }
end

Conference.blueprint do
  title { "FrabCon" }
  acronym { "frabcon#{sn}" }
  timeslot_duration { 15 }
  default_timeslots { 4 }
  max_timeslots { 20 }
  first_day { Date.today.since(60.days) }
  last_day { Date.today.since(61.days) }
end

CallForPapers.blueprint do
  start_date { Date.today.ago(1.days) }
  end_date { Date.today.since(6.days) }
  conference
end

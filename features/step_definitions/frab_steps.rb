Given /^I am not authenticated$/ do
 visit("/users/sign_out") 
end

Given /^I am a new user with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  User.make!(:email => email, :password => password, :confirmed_at => Time.now.ago(1.days))
end

Given /^I am a recurring user logged in to an open cfp$/ do
  u = User.make!(:confirmed_at => Time.now.ago(1.days), :person => Person.make!)
  cfp = CallForPapers.make!
  visit(cfp_root_path(:conference_acronym => cfp.conference.acronym))
  fill_in("Email", :with => u.email)
  fill_in("Password", :with => "frab23")
  click_button("Log in")
end

Given /^I am a new user logged in to an open cfp/ do
  u = User.make!(:confirmed_at => Time.now.ago(1.days))
  cfp = CallForPapers.make!
  visit(cfp_root_path(:conference_acronym => cfp.conference.acronym))
  fill_in("Email", :with => u.email)
  fill_in("Password", :with => "frab23")
  click_button("Log in")
end

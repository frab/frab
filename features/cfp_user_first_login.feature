Feature: Call for Papers user first login 
  In order to submit proposals in a Call for Papers
  A user
  should first be prompted to enter personal details
  
  Scenario: Perform first login 
    Given I am a new user with email "cukes@example.org" and password "cukes23"
      And I am not authenticated
      And I am on an open cfp's home page
    When I fill in "Email" with "cukes@example.org"
      And I fill in "Password" with "cukes23"
      And I press "Sign in"
    Then I should see "Personal details"

  Scenario: Fill in personal details
    Given I am a new user logged in to an open cfp
    When I fill in "First name" with "Fred"
      And I fill in "Last name" with "Besen"
      And I select "male" from "Gender"
      And I press "Create Person"
    Then I should see "Person was successfully created."
      And I should see "Welcome"


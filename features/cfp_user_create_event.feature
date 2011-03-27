Feature: Call for Papers event submission 
  In order to submit proposals in a Call for Papers
  A user
  wants to submit a new event
  
  Scenario: Fill out and submit event submission form
    Given I am recurring user logged in to an open cfp
      And I follow "Submit a new event"
    When I fill in "Title" with "BDD with Cucumber"
      And I fill in "Subtitle" with "Fun with vegetables"
      And I select "01:00" from "Time slots"
      And I press "Create Event"
    Then I should see "Event was successfully created."
      And I should see "BDD with Cucumber"
      And I should see "Submit another event"

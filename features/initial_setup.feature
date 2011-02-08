Feature: Initial setup with no conference
  In order to start using nab
  As a nab user
  I should be prompted to create a new conference
  And then be able to do so.

  Scenario: New conference form after login
    Given I am a new, authenticated user
    When I go to the home page
    Then I should see "Create your first conference"

  Scenario: Create the first conference
    Given I am a new, authenticated user
    When I go to the home page
      And I fill in "acronym" with "froscon3000"
      And I fill in "title" with "FrOSCon"
      And I press "Save Conference"
    Then I should see "Conference created successfully"


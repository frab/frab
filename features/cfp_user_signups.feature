Feature: Call for Papers user signup 
  In order to submit proposals in a Call for Papers
  A user
  wants to sign up and create an account

  Scenario: Go to the signup page
    Given I am not authenticated
      And I am on an open cfp's home page
    When I follow "Sign up"
    Then I should see "Sign up"

  Scenario: Fill out and submit signup form
    Given I am not authenticated
      And I am on an open cfp's home page
      And I follow "Sign up"
    When I fill in "Email" with "cucumber@example.org"
      And I fill in "Password" with "cucumber23"
      And I fill in "Password confirmation" with "cucumber23"
      And I press "Sign up"
    Then I should see "You have signed up successfully. If enabled, a confirmation was sent to your e-mail."

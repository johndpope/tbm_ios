Feature: Login.
  User should be able to login in application.

  Scenario: User should see error if phone number is not filled
    When I enter "Oksana" into input field number 1
    When I enter "Kovalchuk" into input field number 2
    When I enter "380" into input field number 3
    When I touch the "SignIn" button
    Then I should see "Error"


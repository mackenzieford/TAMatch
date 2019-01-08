Feature: TA Application
  As a user that is a TA
  In order to be able to apply for TA positions.
  I want to be able to specify details about my preferences.

Scenario: Input fields for the TA Application 
    Given that I am a student
    When I login as "test_s@x.x"
    When I am on the "TA Application" page 
    And I select "MS Thesis" from "degreeProgram"
    And I check "gCheck"
    Then I want to submit my information
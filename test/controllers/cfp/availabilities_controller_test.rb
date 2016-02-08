require 'test_helper'

class Cfp::AvailabilitiesControllerTest < ActionController::TestCase
  setup do
    @call_for_participation = FactoryGirl.create(:call_for_participation)
    @conference = @call_for_participation.conference
    login_as(:submitter)
  end

  test 'should get new' do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end
end

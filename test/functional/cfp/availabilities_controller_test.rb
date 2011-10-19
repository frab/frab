require 'test_helper'

class Cfp::AvailabilitiesControllerTest < ActionController::TestCase

  setup do
    @call_for_papers = FactoryGirl.create(:call_for_papers)
    @conference = @call_for_papers.conference
    login_as(:submitter)
  end

  test "should get new" do
    get :new, :conference_acronym => @conference.acronym
    assert_response :success
  end

end

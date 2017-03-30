require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  setup do
    @present = create(:three_day_conference, title: 'present conference')
    create(:call_for_participation, conference: @present)
    @past = create(:three_day_conference, title: 'past conference')
    create(:past_call_for_participation, conference: @past)
    @future = create(:three_day_conference, title: 'future conference')
    create(:future_call_for_participation, conference: @future)
  end

  test 'should list of conferences' do
    get :index
    assert_response :success
    assert_includes response.body, '>present conference'
    assert_includes response.body, '>past conference'
    assert_includes response.body, '>future conference'
  end
end

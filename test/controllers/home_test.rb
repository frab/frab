require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  setup do
    @present = create(:three_day_conference, title: 'present conference')
    create(:call_for_participation, conference: @present)
    @past = create(:past_days_conference, title: 'past conference')
    @future = create(:three_day_conference, title: 'future conference')
    create(:conference, title: 'other conference')
  end

  test 'should list all conferences by days' do
    get :index
    assert_response :success
    assert_includes response.body, '>present conference'
    assert_includes response.body, '>future conference'
    refute_includes response.body, '>past conference'
    refute_includes response.body, '>other conference'
  end

  test 'should list all past conferences by days' do
    get :past
    assert_response :success
    assert_includes response.body, '>past conference'
    refute_includes response.body, '>present conference'
    refute_includes response.body, '>future conference'
    refute_includes response.body, '>other conference'
  end
end

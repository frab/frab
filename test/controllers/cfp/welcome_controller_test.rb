require 'test_helper'

class Cfp::WelcomeControllerTest < ActionController::TestCase
  setup do
    @present = create(:three_day_conference, title: 'present conference')
    create(:call_for_participation, conference: @present)
    @past = create(:three_day_conference, title: 'past conference')
    create(:past_call_for_participation, conference: @past)
    @future = create(:three_day_conference, title: 'future conference')
    create(:future_call_for_participation, conference: @future)
  end

  test 'should show cfp for running conference' do
    get :show, params: { conference_acronym: @present.acronym }
    assert_response :success
  end

  test 'should show cfp for past conference' do
    get :show, params: { conference_acronym: @past.acronym }
    assert_response :success
  end

  test 'should show open soon for future conference' do
    get :show, params: { conference_acronym: @future.acronym }
    assert_response :success
  end

  test 'should show non existing for missing conference' do
    assert_raises(ActionController::RoutingError) do
      get :show, params: { conference_acronym: 'non-existing' }
    end
  end
end

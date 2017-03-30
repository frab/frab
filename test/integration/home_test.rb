require 'test_helper'

class TeaserPageTest < ActionDispatch::IntegrationTest
  setup do
    @past_conference = create :three_day_conference_with_events_and_speakers
    create(:past_call_for_participation, conference: @past_conference)
    @conference = create :three_day_conference_with_events_and_speakers
    create(:call_for_participation, conference: @conference)
    create(:conference)
  end

  test 'can list conference teasers' do
    get "/"
    assert_response :success
    #assert_includes @response.body, 'Introducing frap'
  end
end

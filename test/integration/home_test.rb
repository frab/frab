require 'test_helper'

class HomeTest < ActionDispatch::IntegrationTest
  setup do
    @past_conference = create(:three_day_conference_with_events_and_speakers, title: 'PastCon')
    create(:past_call_for_participation, conference: @past_conference)
    @conference = create(:three_day_conference_with_events_and_speakers, title: 'FutureCon')
    create(:call_for_participation, conference: @conference)
    @unlisted = create(:conference, title: 'UnlistedCon')
  end

  test 'can list conference teasers' do
    get '/'
    assert_response :success
    assert_select 'td', @conference.title
    assert_select 'td', @past_conference.title
    refute_includes @response.body, @unlisted.title
  end

  test 'can show conference cfp' do
    get "/#{@conference.acronym}/cfp"
    assert_includes @response.body, "<title>#{@conference.title}<"
    assert_select 'h1', "#{@conference.title}\n- Call for Participation"
    get "/#{@past_conference.acronym}/cfp"
    assert_includes @response.body, "<title>#{@past_conference.title}<"
    assert_select 'h1', "#{@past_conference.title}\n- Call for Participation"
  end
end

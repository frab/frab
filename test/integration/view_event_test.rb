require 'test_helper'

class ViewEventTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create :three_day_conference_with_events_and_speakers
    @event = create :event, conference: @conference
    @conference_user = create :conference_orga, conference: @conference
    sign_in(@conference_user.user)
  end

  test 'can view event details' do
    get "/#{@conference.acronym}/events/#{@event.id}"
    assert_response :success
    assert_includes @response.body, 'Introducing frap'
  end

  test 'can view events table' do
    get "/#{@conference.acronym}/events"
    assert_response :success
    assert_includes @response.body, 'Introducing frap'
    assert_includes @response.body, %'by <a href="/en/people/3?conference_acronym=#{@conference.acronym}">Fred Besen</a>'
  end

  test 'reports no results for missing terms' do
    get "/#{@conference.acronym}/events?q%5Bs%5D=track_name+asc&term=workshop&utf8=%E2%9C%93"
    assert_response :success
    assert_includes @response.body, 'Sorry, but your search yielded no results.'
  end

  test 'finds events for search term' do
    get "/#{@conference.acronym}/events?q%5Bs%5D=track_name+asc&term=frap&utf8=%E2%9C%93"
    assert_response :success
    assert_includes @response.body, 'frap'
  end
end

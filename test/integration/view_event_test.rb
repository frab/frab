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
    assert_includes @response.body, %'by <a href="/en/#{@conference.acronym}/people/#{@conference.events.last.speakers.last.id}">Fred Besen</a>'
  end

  test 'can view my events table' do
    get "/#{@conference.acronym}/events/my"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select "h1", text: "My Events"
  end

  test 'can view attachment overview table' do
    get "/#{@conference.acronym}/events/attachments"
    assert_includes @response.body, 'There are no files attached'
    
    upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'textfile.txt'), 'text/plain')
    @event.update_attributes( event_attachments_attributes: { 'xx' => { 'title' => 'proposal',         'attachment' => upload } }) #todo join lines?
    @event.update_attributes( event_attachments_attributes: { 'yy' => { 'title' => 'a freeform title', 'attachment' => upload } })
                                                                
    get "/#{@conference.acronym}/events/attachments"
    assert_includes @response.body, @event.title

    assert_select 'a', 'a freeform title' # freeform titles appear as clickable names

    assert_includes @response.body, 'proposal' # proposal appears as a table header, not a link
    assert_select 'a', {text: 'proposal', count: 0}
    
  end

  test 'reports no results for missing terms' do
    get "/#{@conference.acronym}/events?q%5Bs%5D=track_name+asc&term=workshop&utf8=%E2%9C%93"
    assert_response :success
    assert_includes @response.body, 'Sorry, but your search yielded no results.'
  end

  test 'finds events for search term' do
    get "/#{@conference.acronym}/events?q%5Bs%5D=track_name+asc&term=#{@conference.events.last.title.split.last}&utf8=%E2%9C%93"
    assert_response :success
    assert_includes @response.body, 'frap'
    assert_includes @response.body, 'Listing 1 of 4 events'
  end
end

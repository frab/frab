require 'test_helper'

class EventsControllerFilteringTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user

    @event1 = @conference.events[0]
    @event2 = @conference.events[1]
    @event3 = @conference.events[2]
    @event1.update!(event_type: 'film')
    @event2.update!(event_type: 'lecture')
    @event3.update!(event_type: 'dance')
    
    sign_in @user
  end
  
  test 'filters events by single event type' do
    get "/#{@conference.acronym}/events", params: { event_type: 'film' }
    
    assert_response :success
    assert_select 'td a', text: @event1.title
    assert_select 'td a', text: @event2.title, count: 0
    assert_select 'td a', text: @event3.title, count: 0
  end
  
  test 'filters events by multiple event types using pipe separator' do
    get "/#{@conference.acronym}/events", params: { event_type: 'film|dance' }
    
    assert_response :success
    assert_select 'td a', text: @event1.title
    assert_select 'td a', text: @event2.title, count: 0
    assert_select 'td a', text: @event3.title
  end
  
  test 'shows all events when no filter is applied' do
    get "/#{@conference.acronym}/events"
    
    assert_response :success
    assert_select 'td a', text: @event1.title
    assert_select 'td a', text: @event2.title
    assert_select 'td a', text: @event3.title
  end
  
end
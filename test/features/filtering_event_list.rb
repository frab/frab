require 'test_helper'

class EditingEventRatingTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user

    @event1 = @conference.events[0]
    @event2 = @conference.events[1]
    @event3 = @conference.events[2]
    @event1.update_attributes(event_type: 'film')
    @event2.update_attributes(event_type: 'lecture')
    @event3.update_attributes(event_type: 'dance')

    EventRating.create(event: @event2, person: @coordinator.person, rating: 3, comment: "comment1")
  end

  it 'can filter event list by clicking a term', js: true do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/"
    
    click_on 'Film'
    assert_content page, '[x] Event type : Film'
    assert_content page, @event1.title
    refute_content page, @event2.title
    refute_content page, @event3.title
  end
end

require 'test_helper'

class EditingEventRatingTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last

    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user

  end

  it 'can create event rating and delete it', js: true do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
    assert_content page, 'My rating'

    find('div#my_rating').find(:xpath, '//img[@title="good"]').click()
    find('textarea').set('Quite good event')
    click_on 'Create Event rating'

    assert_content page, 'My rating'
    assert_content page, 'Quite good event'
    click_on 'Delete Event rating'

    assert_content page, 'My rating'
    refute_content page, 'Quite good event'
  end
end

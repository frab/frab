require 'application_system_test_case'

class EditingEventRatingTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last

    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user

  end

  test 'can create event rating and delete it' do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
    assert_content page, 'My rating'

    # Click on the 4th star (good rating) in the new CSS-only star rating
    find('form').find('label[for$="star4"]').click()
    find('textarea').set('Quite good event')
    click_on 'Create rating'

    assert_content page, 'My rating'
    assert_content page, 'Quite good event'
    accept_alert do
      find('i.bi-trash').click
    end

    assert_content page, 'My rating'
    refute_content page, 'Quite good event'
  end
end

require 'test_helper'

class EditingEventsTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    create(:call_for_participation, conference: @conference)

    @user = create(:conference_reviewer, conference: @conference).user
    create(:event_person, event: @event, person: @user.person, role_state: 'confirmed')

    sign_in_user(@user)
    click_on 'Participate'
  end

  test 'can edit own event in cfp interface' do
    assert_content page, 'Events you already submitted'
    click_on 'edit'
    fill_in 'Title', with: 'A new title', match: :first
    click_on 'Update event'
    assert_content page, 'Event was successfully updated.'
    assert_content page, 'A new title'
  end

  test 'cannot edit own even in admin interface' do
    visit "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_content page, 'This action is not allowed.'
    #save_and_open_page
  end
end

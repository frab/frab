require 'test_helper'

class CfpCanEditEventTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    create(:call_for_participation, conference: @conference)

    @user = create(:cfp_user)
    create(:event_person, event: @event, person: @user.person, role_state: 'confirmed')

    sign_in_user(@user)
    click_on 'Participate'
  end

  test 'can edit own event' do
    assert_content page, 'Events you already submitted'
    click_on 'edit'
    fill_in 'title', with: 'A new title', match: :first
    click_on 'Update event'
    assert_content page, 'Event was successfully updated.'
    assert_content page, 'A new title'
    #save_and_open_page
  end
end

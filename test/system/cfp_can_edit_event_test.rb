require 'application_system_test_case'

class CfpCanEditEventTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    create(:call_for_participation, conference: @conference)

    @user = create(:cfp_user)
    create(:event_person, event: @event, person: @user.person, role_state: 'confirmed')
  end

  test 'can edit own event' do
    sign_in_user(@user)
    click_on 'Participate'
    assert_content page, 'Events you already submitted'
    click_on 'edit'
    fill_in 'Title', with: 'A new title', match: :first
    click_on 'Update event'
    assert_content page, 'Event was successfully updated.'
    assert_content page, 'A new title'
    #save_and_open_page
  end

  test 'presented with limited set of durations' do
    sign_in_user(@user)
    click_on 'Participate'
    click_on 'Submit a new event'
    refute_content page, '00:15'
    refute_content page, '00:30'
    # assert_content page, '00:45'
    # assert_content page, '01:00'
  end
end

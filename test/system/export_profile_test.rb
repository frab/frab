require 'application_system_test_case'

class ExportProfileTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    create(:call_for_participation, conference: @conference)

    @user = create(:cfp_user)
    create(:event_person, event: @event, person: @user.person, role_state: 'confirmed')

    sign_in_user(@user)
    click_on 'Participate'
  end

  test 'export profile' do
    click_on 'Account'
    click_on 'Export profile'
    assert_content page, 'Export Profile'
    assert_content page, 'Profile data'
  end
end

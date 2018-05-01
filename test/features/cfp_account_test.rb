require 'test_helper'

class CfpAccountTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    create(:call_for_participation, conference: @conference)

    @user = create(:cfp_user)
    create(:event_person, event: @event, person: @user.person, role_state: 'confirmed')

    sign_in_user(@user)
  end

  test 'can edit account' do
    assert_content page, 'List of conferences'
    click_on 'Account'
    assert_content page, 'Select a conference to edit'
  end
end

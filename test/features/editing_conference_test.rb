require 'test_helper'

class EditingConferenceTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    create(:event_ticket, object: @conference.events.first)
    @admin = create(:admin_user)
    sign_in_user(@admin)
  end

  test 'set ticket server to RT' do
    assert_content page, 'Conferences'
    visit_conference_settings
    choose('Request Tracker')
    click_on 'Update conference'
    assert_content page, 'Conference was successfully updated.'

    click_on 'Ticket Server'
    fill_in 'Server URL', with: 'https://127.0.0.1/otrs/'
    fill_in 'Queue', with: 'queue1'
    fill_in 'User', with: 'user1'
    fill_in 'Password', with: 'password'
    click_on 'Update conference'
    assert_content page, 'Conference was successfully updated.'
    click_on 'Events'
    assert_content page, 'Events'
    assert_content page, Event.last.title
  end
end

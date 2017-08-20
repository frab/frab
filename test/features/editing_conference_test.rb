require 'test_helper'

class EditingConferenceTest < Capybara::Rails::TestCase
  include CapybaraHelper

  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    create(:event_ticket, object: @conference.events.first)
    @admin = create(:user, role: 'admin', password: 'frab123')
    sign_in(@admin.email, 'frab123')
  end

  test 'set ticket server to RT' do
    assert_content page, 'Conferences'
    visit_conference_settings
    choose('rt')
    click_on 'Update conference'
    assert_content page, 'Conference was successfully updated.'

    click_on 'Ticket Server'
    fill_in 'Url', with: 'https://127.0.0.1/otrs/'
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

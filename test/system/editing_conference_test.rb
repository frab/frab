require 'application_system_test_case'

class EditingConferenceTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    create(:event_ticket, object: @conference.events.first)
    @admin = create(:admin_user)
    sign_in_user(@admin)
  end

  test 'set ticket server to RT' do
    assert_content page, 'Conferences'
    click_on 'Conferences'
    within find('tr', text: @conference.title) do
      click_on 'Show'
    end
    click_on 'More'
    click_on 'Settings'

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
    assert_content page, 'List of events'
    # TODO flaky assert
    assert_content page, Event.last.title
  end

  test 'edit classifiers' do
    visit "/#{@conference.acronym}/conference/edit_classifiers"
    assert_content page, 'Here you can create and edit the classifiers'
    click_on 'Update conference'
    assert_content page, 'Conference was not updated.'
    click_on 'Classifiers'
    click_on 'Add classifier'
    fill_in 'Name', with: 'classifier1'
    click_on 'Update conference'
    assert_content page, 'Conference was successfully updated.'
  end
end

require 'application_system_test_case'

# Generated test cases
class ConferenceManagementSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:conference, acronym: 'testconf', title: 'Test Conference')
    @orga = create(:conference_orga, conference: @conference)
  end

  test 'orga can view conference dashboard' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    assert_content page, 'Events'
    assert_content page, 'People'
  end

  test 'conference dashboard shows statistics section' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    assert_content page, 'Statistics'
  end

  test 'conference dashboard shows recent changes section' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    assert_content page, 'Recent changes'
  end

  test 'conference dashboard shows welcome alert when no rooms exist' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    # Should show welcome message since we haven't created any rooms
    assert_selector '.alert.alert-info'
  end

  test 'conference dashboard shows events by state when events exist' do
    create(:event, conference: @conference, title: 'Test Event')
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    assert_content page, 'Events by state'
    assert_content page, 'Total'
  end
end

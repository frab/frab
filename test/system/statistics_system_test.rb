require 'application_system_test_case'

# Generated test cases
class StatisticsSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @orga = create(:conference_orga, conference: @conference)

    # Create test data for statistics
    @confirmed_event = create(:event, conference: @conference, state: 'confirmed', public: true)
    @new_event = create(:event, conference: @conference, state: 'new')
    @speaker = create(:person, public_name: 'Test Speaker')
    create(:event_person, event: @confirmed_event, person: @speaker, event_role: 'speaker')
  end

  test 'orga can navigate to conference statistics through UI' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    # Navigate through the UI to statistics
    click_on 'More'
    click_on 'Statistics'

    assert_content page, 'Statistics'
    assert_content page, 'Events'
    assert_content page, 'People'
  end

  test 'statistics page shows event breakdown by state' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    # Navigate through UI
    click_on 'More'
    click_on 'Statistics'

    # Should show counts of events by state
    assert_content page, 'confirmed'
    assert_content page, 'new'
  end

  test 'statistics page shows events by state table' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    click_on 'More'
    click_on 'Statistics'

    # Should show events by state statistics
    assert_content page, 'Events by state'
  end

  test 'statistics page shows chart visualization' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    click_on 'More'
    click_on 'Statistics'

    # Should show chart or visualization elements
    assert_content page, 'All'
    assert_content page, 'Lectures only'
    assert_content page, 'Workshops only'
  end

  test 'statistics page handles conference with no events' do
    empty_conference = create(:conference, title: 'Empty Conference', acronym: 'empty2024')
    orga = create(:conference_orga, conference: empty_conference)

    sign_in_user(orga.user)
    visit "/#{empty_conference.acronym}"

    click_on 'More'
    click_on 'Statistics'

    assert_content page, 'Statistics'
    # Should handle empty state gracefully
  end

  test 'coordinator can view statistics through UI navigation' do
    coordinator = create(:conference_coordinator, conference: @conference)

    sign_in_user(coordinator.user)
    visit "/#{@conference.acronym}"

    click_on 'More'
    click_on 'Statistics'

    assert_content page, 'Statistics'
  end

  test 'statistics page shows numerical summary' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}"

    click_on 'More'
    click_on 'Statistics'

    # Should show numerical totals
    assert_content page, 'Total'
  end
end

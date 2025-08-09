require 'application_system_test_case'

# Generated test cases
class EventsManagementSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @orga = create(:conference_orga, conference: @conference)
    @track = create(:track, conference: @conference)
  end

  test 'orga can view events list' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events"

    assert_content page, 'List of events'
    assert_content page, 'Add event'
  end

  test 'orga can create new event' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events"

    click_on 'Add event'

    fill_in 'Title', with: 'Test Event Title', match: :first
    select 'Lecture', from: 'Event type'
    select @track.name, from: 'Track'

    click_on 'Create event'

    assert_content page, 'Event was successfully created'
    assert_content page, 'Test Event Title'
  end

  test 'orga can edit existing event' do
    event = create(:event, conference: @conference, title: 'Original Title', abstract: 'Original abstract')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events/#{event.id}/edit"

    fill_in 'Title', with: 'Updated Event Title', match: :first
    find('input[type="submit"]').click

    assert_content page, 'Event was successfully updated'
    assert_content page, 'Updated Event Title'
  end

  test 'orga can view individual event details' do
    event = create(:event, conference: @conference, title: 'Test Event', abstract: 'Event description')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events/#{event.id}"

    assert_content page, 'Test Event'
    assert_content page, 'Event description'
    assert_content page, 'Edit Event'
  end

  test 'orga can search events by title' do
    event1 = create(:event, conference: @conference, title: 'Ruby Workshop')
    event2 = create(:event, conference: @conference, title: 'Python Tutorial')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events"

    fill_in 'term', with: 'Ruby'
    click_on 'Search'

    assert_content page, 'Ruby Workshop'
    refute_content page, 'Python Tutorial'
  end

  test 'events page has bulk edit functionality when events exist' do
    create(:event, conference: @conference, title: 'Event 1')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events"

    # Should show bulk edit text somewhere
    assert_content page, 'Bulk Edit'
  end

  test 'orga can export events' do
    create(:event, conference: @conference, state: 'confirmed', public: true, title: 'Confirmed Event')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events/export_confirmed.json"

    # Should get JSON response
    assert_current_path "/#{@conference.acronym}/events/export_confirmed.json"
  end

  test 'orga can access print cards functionality' do
    create(:event, conference: @conference, title: 'Test Event for Print')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events"

    # Should have print dropdown
    assert_content page, 'Print'
  end

  test 'events list shows pagination when many events exist' do
    # Create more events than pagination limit (more than 100)
    110.times do |i|
      create(:event, conference: @conference, title: "Event #{i}")
    end

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events"

    # Should show pagination controls
    assert_selector '.pagination'
  end

  test 'events list shows event counts' do
    create(:event, conference: @conference, title: 'Test Event')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/events"

    assert_content page, 'Listing'
  end
end

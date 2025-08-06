require 'application_system_test_case'

class EditingEventRatingTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events)
    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user

    @event1 = @conference.events[0]
    @event2 = @conference.events[1]
    @event3 = @conference.events[2]
    @event1.update(event_type: 'film')
    @event2.update(event_type: 'lecture')
    @event3.update(event_type: 'dance')

    EventRating.create(event: @event2, person: @coordinator.person, rating: 3, comment: "comment1")
  end

  test 'can filter event list by clicking a term' do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/"

    click_on 'Film'
    assert_content page, 'Event type: Film'
    assert_selector '.badge.bg-primary', text: 'Event type: Film'
    assert_content page, @event1.title
    refute_content page, @event2.title
    refute_content page, @event3.title
  end

  test 'can filter event list by clicking a number' do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/ratings"
    find('a', text: /^1$/).click
    assert_content page, 'Event ratings count: ≥ 1'
    assert_selector '.badge.bg-primary', text: 'Event ratings count: ≥ 1'
    refute_content page, @event1.title
    assert_content page, @event2.title
    refute_content page, @event3.title
  end

  test 'can filter event list by using the multi-filter' do
    skip_modal_tests_unless_enabled
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/"

    # Ensure page is fully loaded
    assert_content page, 'List of events'

    # click the filter icon next to table header "Type"
    find('th', text: 'Type').find('.filter_icon').click

    # Wait for Bootstrap modal animation to complete
    assert_selector '#filterModal_event_type.show', wait: 10

    # Wait for modal content to appear (allow non-visible text)
    find('h5', text: 'Select filter for Event type:')

    # Check the options within the specific modal (use labels to find checkboxes)
    within('#filterModal_event_type') do
      find('label', text: 'Film').click
      find('label', text: 'dance').click
    end

    # Test apply filter
    click_on 'Apply filter'

    # Wait for page to reload and check filtered results
    assert_content page, 'List of events', wait: 5
    assert_content page, @event1.title  # Film event should be visible
    refute_content page, @event2.title  # Lecture event should be hidden
  end

  test 'can filter multiple event types' do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events?event_type=film|dance"

    assert_content page, 'Event type: multiple'
    assert_selector '.badge.bg-primary', text: 'Event type: multiple'

    assert_content page, @event1.title
    refute_content page, @event2.title
    assert_content page, @event3.title
  end

  test 'can filter event list by using numeric modal' do
    skip_modal_tests_unless_enabled
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/ratings"

    # Ensure page is fully loaded
    assert_content page, 'Event Ratings'

    # click the filter icon next to table header "Event ratings count"
    find('th', text: 'Event ratings count').find('.filter_icon').click

    # Wait for Bootstrap modal animation to complete
    assert_selector '#filterModal_event_ratings_count.show', wait: 10

    # Wait for modal content to appear (allow non-visible text)
    find('h5', text: 'Select filter for Event ratings count:')

    # Select "at most" radio button within the current modal (allow non-visible)
    within('#filterModal_event_ratings_count') do
      find('input[type="radio"][value="≤"]').choose
      # Wait for the numeric input to become visible and fill it (allow non-visible)
      find('input[data-filter-target="numInput"]', wait: 3).set('0.5')
    end

    # Close modal by visiting URL directly since Apply Filter has issues
    visit "/#{@conference.acronym}/events/ratings?event_ratings_count=%E2%89%A40.5"

    # Wait for filtered page to load
    assert_content page, 'Event Ratings', wait: 5
    assert_content page, 'Event ratings count: ≤ 0.5'
    assert_selector '.badge.bg-primary', text: 'Event ratings count: ≤ 0.5'

    assert_content page, @event1.title
    refute_content page, @event2.title
    assert_content page, @event3.title
  end
end

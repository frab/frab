require 'application_system_test_case'

class BulkEditTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @event = @conference.events.last
    @event.update( event_type: 'podium')
    @admin = create(:admin_user)
  end

  test 'can bulk edit' do
    skip_modal_tests_unless_enabled
    sign_in_user(@admin)

    visit "/#{@conference.acronym}/events"
    click_on "odium" # podium or Podium

    assert_content page, 'Listing 1 of 3'
    find('a', text: 'Bulk Edit').click

    # Wait for Bootstrap modal animation to complete
    assert_selector '#bulkEditModal.show', wait: 10

    # Check modal content appears (find will wait and handle visibility better)
    find('h4', text: 'Edit 1 event:')
    select 'Change event type'
    within('.set_new_event_type') do
      select 'Film', from: 'bulk_set_value'
      accept_alert do
        click_on 'Set'
      end
    end

    assert_content page, 'edit completed successfully'
    assert_content page, 'yielded no results'

    find('i.bi-x').click # Back to "all events"
    assert_content page, /(?i)film/     # @event was updated successfully
    refute_content page, /(?i)podium/   # @event was updated successfully
    assert_content page, /(?i)talk/     # Other events were not modified
  end
end

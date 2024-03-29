require 'application_system_test_case'

class BulkEditTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @event = @conference.events.last
    @event.update( event_type: 'podium')
    @admin = create(:admin_user)
  end

  test 'can bulk edit' do
    sign_in_user(@admin)

    visit "/#{@conference.acronym}/events"
    click_on "odium" # podium or Podium

    assert_content page, 'Listing 1 of 3'
    find('a', text: 'Edit these events').click

    assert_content page, 'Edit 1 event:'
    select 'Change event type'
    find('form.bulk_edit_event_type').select 'Film', from: 'bulk_set_value'
    accept_alert do
      find('form.bulk_edit_event_type').click_on 'Set'
    end

    assert_content page, 'edit completed successfully'
    assert_content page, 'yielded no results'

    click_on '╳' # Back to "all events"
    assert_content page, /(?i)film/     # @event was updated successfully
    refute_content page, /(?i)podium/   # @event was updated successfully
    assert_content page, /(?i)talk/     # Other events were not modified
  end
end

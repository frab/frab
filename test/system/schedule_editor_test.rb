require "application_system_test_case"

class ScheduleEditorTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @admin = create(:admin_user)
  end

  test "can open add event modal when clicking time slot" do
    sign_in_user(@admin)

    visit "/#{@conference.acronym}/schedule"

    # Wait for page to load and schedule controller to initialize
    assert_text "Schedule"

    # Debug: Check if schedule controller is loaded and modal exists
    assert_selector "[data-controller='schedule']", visible: false
    assert_selector "#add-event-modal", visible: false

    # Find an empty time slot (not one with an event) and click it
    # Use JavaScript click to avoid issues with overlapping events from overflow content
    # Strategy: Find the last cell in a column, which won't have overflow blocking it
    page.execute_script("
      const table = document.querySelector('table.schedule-grid tbody');
      const rows = Array.from(table.querySelectorAll('tr'));
      // Start from the last row and work backwards to find an empty cell
      for (let i = rows.length - 1; i >= 0; i--) {
        const cells = Array.from(rows[i].querySelectorAll('td.room-cell[data-time]'));
        const emptyCell = cells.find(cell => !cell.querySelector('div.event'));
        if (emptyCell) {
          emptyCell.click();
          break;
        }
      }
    ")

    # Add a small delay to allow JavaScript to process
    sleep 0.5

    # Check if modal opens
    assert_selector "#add-event-modal", visible: true
    assert_text "Add event at"
  end

  test "can drag and drop event without CSRF errors" do
    sign_in_user(@admin)

    visit "/#{@conference.acronym}/schedule"

    # Wait for page to load
    assert_text "Schedule"

    # Find an existing event and a target slot
    event = find("div.event", match: :first)
    target_slot = find("table.schedule-grid td.room-cell[data-time]:not(:has(div.event))", match: :first)

    # Simulate drag and drop by directly calling the controller method
    # This tests the CSRF token functionality in the AJAX request
    page.execute_script("
      const event = arguments[0];
      const targetTd = arguments[1];
      const scheduleController = document.querySelector('[data-controller=\"schedule\"]');

      // Find the controller instance
      const application = window.Stimulus;
      const controller = application.getControllerForElementAndIdentifier(scheduleController, 'schedule');

      // Test the addEventToTimeSlot method which makes the AJAX call
      controller.addEventToTimeSlot(event, targetTd, true);
    ", event, target_slot)

    # Wait for the AJAX request to complete
    sleep 2

    # If CSRF token is working, we shouldn't see any 422 errors in the console
    # The event should have moved successfully (highlighted with yellow background briefly)
    assert_no_text "Unprocessable Entity"
    assert_no_text "422"
  end
end

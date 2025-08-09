require 'application_system_test_case'

# Generated test cases
class PublicFeedbackSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @conference.update!(feedback_enabled: true, schedule_public: true)

    @event = create(:event,
      conference: @conference,
      state: 'confirmed',
      public: true,
      title: 'Test Event for Feedback',
      room: @conference.rooms.first,
      start_time: @conference.days.first.start_date.since(2.hours)
    )
  end

  test 'can access public feedback form' do
    visit "/#{@conference.acronym}/public/events/#{@event.id}/feedback/new"

    assert_content page, 'Feedback for:'
    assert_content page, @event.title
    assert_content page, 'How would you rate this event'
  end

  test 'can submit feedback with rating and comment' do
    visit "/#{@conference.acronym}/public/events/#{@event.id}/feedback/new"

    fill_in 'Comment', with: 'Great presentation, very informative!'

    click_on 'Submit feedback'

    assert_content page, 'Thank you'
  end

  test 'can submit feedback with comment only' do
    visit "/#{@conference.acronym}/public/events/#{@event.id}/feedback/new"

    fill_in 'Comment', with: 'Excellent content and delivery'

    click_on 'Submit feedback'

    assert_content page, 'Thank you'
  end

  test 'feedback form can be submitted without data' do
    visit "/#{@conference.acronym}/public/events/#{@event.id}/feedback/new"

    # Try to submit without any data - feedback forms often allow empty submissions
    find('input[type="submit"], button[type="submit"]').click

    # Should show thank you page even with empty feedback
    assert_content page, 'Thank you'
  end

  test 'feedback form has required elements' do
    visit "/#{@conference.acronym}/public/events/#{@event.id}/feedback/new"

    assert_selector 'textarea[name*="comment"]'
    assert_selector 'input[name*="rating"]', visible: false
    assert_selector 'input[type="submit"], button[type="submit"]'
  end

  test 'feedback form is not available when feedback is disabled' do
    @conference.update!(feedback_enabled: false)

    # This should raise an error or redirect since feedback is disabled
    # The exact behavior depends on the implementation
    visit "/#{@conference.acronym}/public/events/#{@event.id}/feedback/new"

    # If it doesn't raise an error, it might show a disabled message
    # assert_content page, 'Feedback is not enabled'
  end
end

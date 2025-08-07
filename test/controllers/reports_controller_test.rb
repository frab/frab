require 'test_helper'

# Generated test cases
class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @orga = create(:conference_orga, conference: @conference)

    # Create different types of events for testing reports
    @confirmed_event = create(:event, conference: @conference, state: 'confirmed', event_type: 'lecture', public: true)
    @workshop_event = create(:event, conference: @conference, state: 'new', event_type: 'workshop')
    @private_event = create(:event, conference: @conference, state: 'confirmed', public: false)
    @event_with_note = create(:event, conference: @conference, state: 'confirmed', note: 'Important note')

    # Add speakers
    @speaker = create(:person)
    create(:event_person, event: @confirmed_event, person: @speaker, event_role: 'speaker', role_state: 'confirmed')
  end

  test 'orga can access reports index' do
    sign_in @orga.user
    get "/#{@conference.acronym}/reports"

    assert_response :success
    assert_select 'h1', text: /Reports/i
  end

  test 'orga can view events not public report' do
    sign_in @orga.user
    get "/#{@conference.acronym}/reports/on_events/events_not_public"

    assert_response :success
    assert_includes response.body, @private_event.title
  end

  test 'orga can view workshops report' do
    sign_in @orga.user
    get "/#{@conference.acronym}/reports/on_events/events_that_are_workshops"

    assert_response :success
    assert_includes response.body, @workshop_event.title
  end

  test 'orga can view events with notes report' do
    sign_in @orga.user
    get "/#{@conference.acronym}/reports/on_events/events_with_a_note"

    assert_response :success
    assert_includes response.body, @event_with_note.title
  end

  test 'non-orga cannot access reports' do
    user = create(:user)
    sign_in user
    get "/#{@conference.acronym}/reports"

    assert_response :redirect
  end
end

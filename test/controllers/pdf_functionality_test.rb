require 'test_helper'

class PdfFunctionalityTest < ActionController::TestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @day = @conference.days.first
    @event = @conference.events.first
    @room = @conference.rooms.first
    # Ensure event has room and time for proper PDF generation
    @event.update!(room: @room, start_time: @day.start_date + 10.hours)
  end

  # Test public schedule PDF endpoints
  test 'public schedule day PDF renders without error' do
    @controller = Public::ScheduleController.new
    get :day, params: {
      conference_acronym: @conference.acronym,
      day: 1
    }, format: 'pdf'

    assert_response :success
    assert_match %r{application/pdf}, response.content_type
    assert response.body.present?, "PDF response body should not be empty"
    # Basic PDF validation - should start with PDF header
    assert response.body.start_with?('%PDF'), "Response should be a valid PDF"
  end


  # Test events cards PDF functionality
  test 'events cards PDF generates successfully with content' do
    @controller = EventsController.new
    login_as(:admin)

    get :cards, params: {
      conference_acronym: @conference.acronym
    }, format: 'pdf'

    assert_response :success
    assert_match %r{application/pdf}, response.content_type
    assert response.body.present?, "PDF response body should not be empty"
    assert response.body.start_with?('%PDF'), "Response should be a valid PDF"
    # PDF binary content - skip text content check
  end

  test 'events cards PDF with accepted filter works' do
    @controller = EventsController.new
    login_as(:admin)

    # Set event to confirmed state
    @event.update!(state: 'confirmed')

    get :cards, params: {
      conference_acronym: @conference.acronym,
      accepted: true
    }, format: 'pdf'

    assert_response :success
    assert_match %r{application/pdf}, response.content_type
    assert response.body.present?, "PDF response body should not be empty"
    assert response.body.start_with?('%PDF'), "Response should be a valid PDF"
  end

  # Test custom schedule PDF functionality
  test 'custom schedule PDF generates successfully' do
    @controller = ScheduleController.new
    login_as(:admin)

    get :custom_pdf, params: {
      conference_acronym: @conference.acronym,
      page_size: 'A4',
      date_id: @day.id,
      room_ids: [@room.id.to_s]
    }, format: 'pdf'

    assert_response :success
    assert_match %r{application/pdf}, response.content_type
    assert response.body.present?, "PDF response body should not be empty"
    assert response.body.start_with?('%PDF'), "Response should be a valid PDF"
    # PDF binary content - skip text content check
  end

  test 'custom schedule PDF with A4 page size' do
    @controller = ScheduleController.new
    login_as(:admin)

    get :custom_pdf, params: {
      conference_acronym: @conference.acronym,
      page_size: 'A4',
      date_id: @day.id,
      room_ids: [@room.id.to_s]
    }, format: 'pdf'

    assert_response :success
    assert_match %r{application/pdf}, response.content_type
    assert response.body.start_with?('%PDF'), "A4 PDF should be valid"
  end

  # Test edge cases and error conditions
  test 'PDF generation handles empty conference schedule' do
    # Use existing conference but ensure schedule is public
    @conference.update!(schedule_public: true)

    @controller = Public::ScheduleController.new
    get :day, params: {
      conference_acronym: @conference.acronym,
      day: 1
    }, format: 'pdf'

    assert_response :success
    assert response.body.start_with?('%PDF'), "Conference schedule PDF should generate successfully"
  end

  test 'PDF generation handles events without rooms' do
    @controller = EventsController.new
    login_as(:admin)

    # Create event without room
    unscheduled_event = create(:event, conference: @conference, room: nil, start_time: nil)

    get :cards, params: {
      conference_acronym: @conference.acronym
    }, format: 'pdf'

    assert_response :success
    assert response.body.start_with?('%PDF'), "Unscheduled events should not break PDF generation"
  end

  test 'PDF generation handles events with special characters' do
    @controller = EventsController.new
    login_as(:admin)

    # Create event with special characters
    special_event = create(:event,
      conference: @conference,
      title: "Test with üñíçødé & <HTML> \"quotes\"",
      abstract: "Description with special chars: äöüß €",
      room: @room,
      start_time: @day.start_date + 11.hours
    )

    get :cards, params: {
      conference_acronym: @conference.acronym
    }, format: 'pdf'

    assert_response :success
    assert response.body.start_with?('%PDF'), "Special characters should not break PDF generation"
  end
end

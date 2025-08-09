require 'application_system_test_case'

# Generated test cases
class PublicScheduleSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @conference.update!(schedule_public: true)

    @public_event = create(:event,
      conference: @conference,
      state: 'confirmed',
      public: true,
      title: 'Public Event',
      abstract: 'This is a public event for testing',
      room: @conference.rooms.first,
      start_time: @conference.days.first.start_date.since(10.hours)
    )

    @speaker = create(:person, public_name: 'Jane Speaker', description: 'Expert speaker')
    create(:event_person, event: @public_event, person: @speaker, event_role: 'speaker', role_state: 'confirmed')
  end

  test 'can view public schedule without authentication' do
    visit "/#{@conference.acronym}/public/schedule"

    assert_content page, @conference.title
    assert_content page, @public_event.title
  end

  test 'can view events list' do
    visit "/#{@conference.acronym}/public/events"

    assert_content page, 'Events'
    assert_content page, @public_event.title
  end

  test 'can view individual event details' do
    visit "/#{@conference.acronym}/public/events/#{@public_event.id}"

    assert_content page, @public_event.title
    assert_content page, @public_event.abstract
    assert_content page, @speaker.public_name
  end

  test 'can view speakers list' do
    visit "/#{@conference.acronym}/public/speakers"

    assert_content page, 'Speakers'
    assert_content page, @speaker.public_name
  end

  test 'can view individual speaker page' do
    visit "/#{@conference.acronym}/public/speakers/#{@speaker.id}"

    assert_content page, @speaker.public_name
    assert_content page, @speaker.description
    assert_content page, @public_event.title
  end

  test 'can view timeline view' do
    visit "/#{@conference.acronym}/public/timeline"

    assert_content page, @public_event.title
  end

  test 'schedule shows room information' do
    visit "/#{@conference.acronym}/public/schedule"

    assert_content page, @conference.rooms.first.name
  end

  test 'private events are not visible in public schedule' do
    private_event = create(:event,
      conference: @conference,
      state: 'confirmed',
      public: false,
      title: 'Private Event',
      room: @conference.rooms.first
    )

    visit "/#{@conference.acronym}/public/schedule"

    assert_content page, @public_event.title
    refute_content page, private_event.title
  end

  test 'schedule has navigation elements' do
    visit "/#{@conference.acronym}/public/schedule"

    assert_content page, 'Speakers'
    assert_content page, 'Events'
    assert_content page, 'Timeline'
  end

  test 'private schedule requires authentication' do
    @conference.update!(schedule_public: false)

    visit "/#{@conference.acronym}/public/schedule"

    # Should redirect to login or show auth required message
    assert_current_path new_user_session_path
  end
end

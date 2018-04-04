require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = create(:event)
    @conference = @event.conference
    @room = create(:room, conference: @conference)
    login_as(:admin)
  end

  def event_params
    # TODO easier way?
    @event.attributes.except('id', 'created_at', 'updated_at', 'conference_id', 'logo_file_name', 'logo_content_type', 'logo_file_size', 'logo_updated_at', 'average_rating', 'event_ratings_count', 'speaker_count', 'event_feedbacks_count', 'average_feedback', 'guid')
  end

  test 'should get index' do
    get :index, params: { conference_acronym: @conference.acronym }
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test 'should search and find a conference' do
    get :index, params: { conference_acronym: @conference.acronym, q: { s: 'acronym asc' }, term: @conference.title }
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test 'should search and not find any conference' do
    get :index, params: { conference_acronym: @conference.acronym, q: { s: 'track_name asc' }, term: 'barf' }
    assert_response :success
    assert_empty assigns(:events)
  end

  test 'should get new' do
    get :new, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should create event' do
    assert_difference('Event.count') do
      post :create, params: { event: event_params, conference_acronym: @conference.acronym }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test 'should show event' do
    get :show, params: { id: @event.to_param, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @event.to_param, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update event' do
    put :update, params: { id: @event.to_param, event: event_params, conference_acronym: @conference.acronym }
    assert_redirected_to event_path(assigns(:event))
  end

  test 'should destroy event' do
    assert_difference('Event.count', -1) do
      delete :destroy, params: { id: @event.to_param, conference_acronym: @conference.acronym }
    end

    assert_redirected_to events_path
  end

  test 'should get cards pdf' do
    conference = create :three_day_conference_with_events
    get :cards, params: { conference_acronym: conference.acronym }, format: 'pdf'
    assert_response :success
  end

  test 'should get accepted cards pdf' do
    conference = create :three_day_conference_with_events
    get :cards, params: { accepted: true, conference_acronym: conference.acronym }, format: 'pdf'
    assert_response :success
  end

  test 'should get index as JSON' do
    event_id = create(:event, conference: @conference, start_time: Time.now, room: @room, note: 'fake-note').id

    get :index, format: :json, params: { conference_acronym: @conference.acronym }
    assert_response :success
    events = JSON.parse(response.body)['events']
    assert_equal 2, events.count
    event_keys = events.find { |e| e['id'] == event_id }.keys
    assert_includes event_keys, 'speakers'
    assert_includes event_keys, 'attachments'
    assert_includes event_keys, 'event_classifiers'
    assert_includes event_keys, 'speaker_ids'
    assert_includes event_keys, 'start_time'
    assert_includes event_keys, 'state'
    refute_includes event_keys, 'note'
  end

  test 'should get index as JSON for crew member' do
    event_id = create(:event, conference: @conference, start_time: Time.now, room: @room, note: 'fake-note').id
    conference_user = create(:conference_reviewer, conference: @conference)
    sign_in(conference_user.user)
    create(:event, conference: @conference, start_time: Time.now, room: create(:room, conference: @conference))

    get :index, format: :json, params: { conference_acronym: @conference.acronym }
    assert_response :success
    events = JSON.parse(response.body)['events']
    event_keys = events.find { |e| e['id'] == event_id }.keys
    refute_includes event_keys, 'speaker_ids'
    refute_includes event_keys, 'start_time'
    refute_includes event_keys, 'state'
  end

  test 'should show event as JSON' do
    get :show, format: :json, params: { id: @event.to_param, conference_acronym: @conference.acronym }
    assert_response :success
    event = JSON.parse(response.body)
    assert_includes event.keys, 'speakers'
  end

  test 'should get export accepted' do
    conference = create :three_day_conference_with_events_and_speakers
    get :export_accepted, params: { conference_acronym: conference.acronym }, format: :json
    assert_response :success
    assert_includes response.body, '[{"event_id":'
  end

  test 'should get export confirmed' do
    conference = create :three_day_conference_with_events_and_speakers
    get :export_confirmed, params: { conference_acronym: conference.acronym }, format: :json
    assert_response :success
    events = JSON.parse(response.body)
    assert_includes events[0].keys, 'speakers'
  end
end

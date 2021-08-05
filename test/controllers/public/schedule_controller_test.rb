require 'test_helper'

class Public::ScheduleControllerTest < ActionController::TestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
  end

  test 'displays schedule main page' do
    get :index, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'displays xml schedule' do
    get :index, format: :xml, params: { conference_acronym: @conference.acronym }
    assert_response :success
    schedule = Hash.from_xml(response.body)['schedule']
    assert_includes schedule.keys, 'conference'
    assert_includes schedule.keys, 'day'
    assert_includes schedule['conference'].keys, 'time_zone_name'
  end

  test 'displays json schedule' do
    get :index, format: :json, params: { conference_acronym: @conference.acronym }
    assert_response :success
    schedule = JSON.parse(response.body)['schedule']
    assert_includes schedule.keys, 'conference'
    assert_includes schedule['conference'].keys, 'time_zone_name'
  end

  test 'displays ical schedule' do
    get :index, format: :ics, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'displays xcal schedule' do
    get :index, format: :xcal, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'displays schedule for a day' do
    get :day, params: { day: 1, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'displays pdf schedule for a day' do
    get :day, params: { day: 1, conference_acronym: @conference.acronym }, format: 'pdf'
    assert_response :success
  end

  test 'display first day' do
    get :day, params: { day: 1, conference_acronym: @conference.acronym }, format: 'pdf'
    assert_response :success
  end

  test 'display an event' do
    get :events, params: { id: 1, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'displays events list' do
    get :events, params: { conference_acronym: @conference.acronym }
    assert_response :success
    get :events, params: { conference_acronym: @conference.acronym }, format: :xls
    assert_response :success
  end

  test 'displays speakers list' do
    get :speakers, params: { conference_acronym: @conference.acronym }
    assert_response :success
    get :speakers, params: { conference_acronym: @conference.acronym }, format: :xls
    assert_response :success
  end

  test 'display a speaker' do
    get :speakers, params: { id: 1, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'displays qr code' do
    get :qrcode, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'json schedule contains the conference events' do
    get :events, format: :json, params: { conference_acronym: @conference.acronym }
    assert_response :success

    data = JSON.parse(@response.body)
    events = data['conference_events']['events']

    assert_equal events.count, @conference.events.count
  end

  test 'json schedule contains the sub-conference events' do
    subc = @conference.subs.first
    subc.rooms << create(:room, conference: subc)
    subc.events << create(:event, conference: subc,
                                  room: subc.rooms.first,
                                  state: 'confirmed',
                                  public: true,
                                  start_time: Date.today.since(1.day).since(11.hours))

    get :events, format: :json, params: { conference_acronym: @conference.acronym }
    assert_response :success

    data = JSON.parse(@response.body)
    events = data['conference_events']['events']

    assert_equal events.count, @conference.events.count + subc.events.count
  end
end

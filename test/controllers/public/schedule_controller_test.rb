require 'test_helper'

class Public::ScheduleControllerTest < ActionController::TestCase
  setup do
    @conference = FactoryGirl.create(:three_day_conference_with_events)
  end

  test 'displays schedule main page' do
    get :index, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'displays xml schedule' do
    get :index, format: :xml, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'displays json schedule' do
    get :index, format: :json, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'displays ical schedule' do
    get :index, format: :ics, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'displays xcal schedule' do
    get :index, format: :xcal, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'displays schedule for a day' do
    get :day, day: 0, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'displays pdf schedule for a day' do
    get :day, day: 0, conference_acronym: @conference.acronym, format: 'pdf'
    assert_response :success
  end

  test 'displays events list' do
    get :day, day: 0, conference_acronym: @conference.acronym, format: 'pdf'
    assert_response :success
  end

  test 'display an event' do
    get :events, id: 1, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'displays speakers list' do
    get :events, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'display a speaker' do
    get :speakers, id: 1, conference_acronym: @conference.acronym
    assert_response :success
  end
end

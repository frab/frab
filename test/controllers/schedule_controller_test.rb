require 'test_helper'

class ScheduleControllerTest < ActionController::TestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @user = login_as(:admin)
  end

  test 'should get index' do
    get :index, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should get update_track' do
    get :update_track, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should get update_event' do
    event = @conference.events.first
    room = @conference.rooms.first
    put :update_event, format: :js, params: { conference_acronym: @conference.acronym, id: event.id, event: { room_id: room.id } }
    assert_response :success
  end

  test 'should get new_pdf' do
    get :new_pdf, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should get custom_pdf' do
    get :custom_pdf, params: {
      conference_acronym: @conference.acronym,
      page_size: 'A4',
      date_id: @conference.days.first.id,
      room_ids: @conference.rooms.map(&:id),
      half_page: '1'
    }
    assert_response :success
  end

  test 'should get html_exports' do
    get :html_exports, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  # test 'should get create_static_export' do
  #   post :create_static_export, params: { conference_acronym: @conference.acronym, export_locale: 'en' }
  #   assert_response :redirect
  # end

  test 'should get download_static_export' do
    get :download_static_export, params: { conference_acronym: @conference.acronym, export_locale: 'en' }
    assert_response :redirect
  end
end

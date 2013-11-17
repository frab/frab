require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    login_as(:admin)
  end

  test "should get index" do
    get :index, conference_acronym: @conference.acronym
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, event: @event.attributes, conference_acronym: @conference.acronym
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, id: @event.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update event" do
    put :update, id: @event.to_param, event: @event.attributes, conference_acronym: @conference.acronym
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event.to_param, conference_acronym: @conference.acronym 
    end

    assert_redirected_to events_path
  end

  test "should get cards pdf" do
    conference = FactoryGirl.create :three_day_conference_with_events
    get :cards, conference_acronym: conference.acronym, format: 'pdf'
    assert_response :success
  end

  test "should get accepted cards pdf" do
    conference = FactoryGirl.create :three_day_conference_with_events
    get :cards, accepted: true, conference_acronym: conference.acronym, format: 'pdf'
    assert_response :success
  end
end

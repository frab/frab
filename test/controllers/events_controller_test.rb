require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    login_as(:admin)
  end

  def event_params
    # TODO easier way?
    @event.attributes.except(*%w(id created_at updated_at conference_id logo_file_name logo_content_type logo_file_size logo_updated_at average_rating event_ratings_count speaker_count event_feedbacks_count average_feedback guid number_of_repeats other_locations methods resources target_audience_experience target_audience_experience_text))
  end

  test 'should get index' do
    get :index, conference_acronym: @conference.acronym
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test 'should get new' do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should create event' do
    assert_difference('Event.count') do
      post :create, event: event_params, conference_acronym: @conference.acronym
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test 'should show event' do
    get :show, id: @event.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @event.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should update event' do
    put :update, id: @event.to_param, event: event_params, conference_acronym: @conference.acronym
    assert_redirected_to event_path(assigns(:event))
  end

  test 'should destroy event' do
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event.to_param, conference_acronym: @conference.acronym
    end

    assert_redirected_to events_path
  end

  test 'should get cards pdf' do
    conference = FactoryGirl.create :three_day_conference_with_events
    get :cards, conference_acronym: conference.acronym, format: 'pdf'
    assert_response :success
  end

  test 'should get accepted cards pdf' do
    conference = FactoryGirl.create :three_day_conference_with_events
    get :cards, accepted: true, conference_acronym: conference.acronym, format: 'pdf'
    assert_response :success
  end
end

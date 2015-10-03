require 'test_helper'

class EventRatingsControllerTest < ActionController::TestCase
  setup do
    @conference = create :conference, :with_events
    @event = Event.last
    @user = login_as(:admin)
  end

  test 'should get show' do
    get :show, conference_acronym: @conference.acronym, event_id: @event.id
    assert_response :success
  end

  test 'should create rating' do
    post :create, conference_acronym: @conference.acronym, event_id: @event.id, event_rating: attributes_for(:event_rating)
    assert_redirected_to event_event_rating_path
  end

  test 'should update rating' do
    event_rating = create :event_rating, event: @event, person: @user.person

    event_rating.rating = 1.0
    patch :update, conference_acronym: @conference.acronym, event_id: @event.id, event_rating: event_rating.attributes
    assert_redirected_to event_event_rating_path
    assert_equal 1.0, event_rating.reload.rating
  end
end

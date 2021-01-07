require 'test_helper'

class Public::FeedbackControllerTest < ActionController::TestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @event = create(:event, conference: @conference, public: true, state: :scheduled, room_id: Room.first.id, start_time: Time.now)
  end

  test 'feedback form gets displayed' do
    get :new, params: { conference_acronym: @conference.acronym, event_id: @event.id, day: @conference.days.first }
    assert_response :success
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:feedback)
  end

  test 'feedback gets created' do
    assert_difference 'EventFeedback.count' do
      post :create, params: { conference_acronym: @conference.acronym, event_id: @event.id, event_feedback: { rating: 3 } }
    end
  end

  test 'feedback gets created via json' do
    assert_difference 'EventFeedback.count' do
      post :create, params: { conference_acronym: @conference.acronym, event_id: @event.id, event_feedback: { rating: 3 } }, format: :json
    end
    assert_response :success
  end
end

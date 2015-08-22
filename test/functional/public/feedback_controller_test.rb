require 'test_helper'

class Public::FeedbackControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
  end

  test "feedback form gets displayed" do
    get :new, conference_acronym: @conference.acronym, event_id: @event.id, day: @conference.days.first
    assert_response :success
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:feedback)
  end

  test "feedback gets created" do
    assert_difference 'EventFeedback.count' do
      post :create, conference_acronym: @conference.acronym, event_id: @event.id, event_feedback: { rating: 3 }
    end
  end
end

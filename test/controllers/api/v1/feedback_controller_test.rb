require 'test_helper'

class Api::V1::FeedbackControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @conference.update!(feedback_enabled: true)
    @event = @conference.events.first
    @event.update!(public: true, state: :scheduled, room: @conference.rooms.first, start_time: Time.now)
    @token = @conference.feedback_token
  end

  test 'creates feedback with standard token header' do
    assert_difference 'EventFeedback.count' do
      post "/api/v1/#{@conference.acronym}/events/#{@event.id}/feedback",
           params: { rating: 4 },
           headers: { 'Authorization' => "Token token=#{@token}" }
    end
    assert_response :created
  end

  test 'rejects feedback with wrong token' do
    assert_no_difference 'EventFeedback.count' do
      post "/api/v1/#{@conference.acronym}/events/#{@event.id}/feedback",
           params: { rating: 4 },
           headers: { 'Authorization' => 'Token token=wrong' }
    end
    assert_response :unauthorized
  end

  test 'rejects feedback without token' do
    assert_no_difference 'EventFeedback.count' do
      post "/api/v1/#{@conference.acronym}/events/#{@event.id}/feedback",
           params: { rating: 4 }
    end
    assert_response :unauthorized
  end

  test 'rejects feedback when feedback disabled' do
    @conference.update!(feedback_enabled: false)
    assert_no_difference 'EventFeedback.count' do
      post "/api/v1/#{@conference.acronym}/events/#{@event.id}/feedback",
           params: { rating: 4 },
           headers: { 'Authorization' => "Token token=#{@token}" }
    end
    assert_response :forbidden
  end

  test 'rejects invalid rating' do
    assert_no_difference 'EventFeedback.count' do
      post "/api/v1/#{@conference.acronym}/events/#{@event.id}/feedback",
           params: { rating: 6 },
           headers: { 'Authorization' => "Token token=#{@token}" }
    end
    assert_response :unprocessable_entity
  end

  test 'returns not found for unknown event' do
    post "/api/v1/#{@conference.acronym}/events/0/feedback",
         params: { rating: 3 },
         headers: { 'Authorization' => "Token token=#{@token}" }
    assert_response :not_found
  end

  test 'batch creates multiple feedbacks' do
    event2 = create(:event, conference: @conference, public: true, state: :scheduled,
                    room: @conference.rooms.first, start_time: Time.now)
    assert_difference 'EventFeedback.count', 2 do
      post "/api/v1/#{@conference.acronym}/feedback/batch",
           params: { ratings: [
             { event_id: @event.id, rating: 5 },
             { event_id: event2.id, rating: 2 }
           ] },
           headers: { 'Authorization' => "Token token=#{@token}" },
           as: :json
    end
    assert_response :created
    body = JSON.parse(response.body)
    assert_equal 2, body['created']
  end

  test 'batch returns multi_status when some fail' do
    assert_difference 'EventFeedback.count', 1 do
      post "/api/v1/#{@conference.acronym}/feedback/batch",
           params: { ratings: [
             { event_id: @event.id, rating: 4 },
             { event_id: 0, rating: 3 }
           ] },
           headers: { 'Authorization' => "Token token=#{@token}" },
           as: :json
    end
    assert_response :multi_status
  end

  test 'batch rejects empty ratings array' do
    post "/api/v1/#{@conference.acronym}/feedback/batch",
         params: { ratings: [] },
         headers: { 'Authorization' => "Token token=#{@token}" },
         as: :json
    assert_response :unprocessable_entity
  end
end

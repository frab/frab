require 'test_helper'

class Cfp::EventsControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    @user = login_as(:submitter)
  end

  def event_params
    @event.attributes.except(*%w(id created_at updated_at conference_id logo_file_name logo_content_type logo_file_size logo_updated_at average_rating event_ratings_count speaker_count event_feedbacks_count average_feedback guid number_of_repeats other_locations methods resources target_audience_experience target_audience_experience_text state start_time public room_id note recording_license))
  end

  test "should get new" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, event: event_params, conference_acronym: @conference.acronym
    end
    assert_response :redirect
  end

  test "should get edit" do
    FactoryGirl.create(:event_person, event: @event, person: @user.person)
    get :edit, id: @event.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update event" do
    FactoryGirl.create(:event_person, event: @event, person: @user.person)
    put :update, id: @event.to_param, event: event_params, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test "should confirm event and login user" do
    session[:user_id] = nil
    @event.update_attributes(state: "unconfirmed")
    event_person = FactoryGirl.create(:event_person, event: @event, person: @user.person)
    event_person.generate_token!
    get :confirm, conference_acronym: @conference.acronym, id: @event.id, token: event_person.confirmation_token
    assert_response :redirect
    @event.reload
    assert_equal "confirmed", @event.state
    assert_not_nil session[:user_id]
  end

  test "should confirm event without user" do
    session[:user_id] = nil
    @event.update_attributes(state: "unconfirmed")
    person = FactoryGirl.create(:person)
    event_person = FactoryGirl.create(:event_person, event: @event, person: person)
    event_person.generate_token!
    get :confirm, conference_acronym: @conference.acronym, id: @event.id, token: event_person.confirmation_token
    assert_response :success
    @event.reload
    assert_equal "confirmed", @event.state
  end
end

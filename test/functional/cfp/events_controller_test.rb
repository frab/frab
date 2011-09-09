require 'test_helper'

class Cfp::EventsControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    @user = login_as(:submitter)
  end

  test "should get new" do
    get :new, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, :event => @event.attributes, :conference_acronym => @conference.acronym
    end
    assert_response :redirect
  end

  test "should get edit" do
    FactoryGirl.create(:event_person, :event => @event, :person => @user.person)
    get :edit, :id => @event.to_param, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should update event" do
    FactoryGirl.create(:event_person, :event => @event, :person => @user.person)
    put :update, :id => @event.to_param, :event => @event.attributes, :conference_acronym => @conference.acronym
    assert_response :redirect
  end

end

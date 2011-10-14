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

  test "should confirm event and login user" do
    session[:user_id] = nil
    @event.update_attributes(:state => "unconfirmed")
    event_person = FactoryGirl.create(:event_person, :event => @event, :person => @user.person)
    event_person.generate_token!
    get :confirm, :conference_acronym => @conference.acronym, :id => @event.id, :token => event_person.confirmation_token
    assert_response :redirect
    @event.reload
    assert_equal "confirmed", @event.state
    assert_not_nil session[:user_id]
  end
  
  test "should confirm event without user" do
    session[:user_id] = nil
    @event.update_attributes(:state => "unconfirmed")
    person = FactoryGirl.create(:person)
    event_person = FactoryGirl.create(:event_person, :event => @event, :person => person)
    event_person.generate_token!
    get :confirm, :conference_acronym => @conference.acronym, :id => @event.id, :token => event_person.confirmation_token
    assert_response :success
    @event.reload
    assert_equal "confirmed", @event.state
  end

end

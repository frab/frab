require 'test_helper'

class CallForParticipationsControllerTest < ActionController::TestCase

  setup do
    @call_for_participation = FactoryGirl.create(:call_for_participation)
    @conference = @call_for_participation.conference
    login_as(:admin)
  end

  test "should show cfp" do
    get :show, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should get new" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should create cfp" do
    new_conference = FactoryGirl.create(:conference)
    assert_difference('CallForParticipation.count') do
      call_for_participation = FactoryGirl.build(:call_for_participation, conference: new_conference)
      post :create, call_for_participations: call_for_participation.attributes, conference_acronym: new_conference.acronym
    end
  end

  test "should get edit" do
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update cfp" do
    put :update, call_for_participations: @call_for_participation.attributes.merge(welcome_text: "welcome"), conference_acronym: @conference.acronym
    assert_redirected_to call_for_participation_path(conference_acronym: @conference.acronym)
  end

  test "should get edit notification" do
    get :edit_notification, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should add cfp notification" do
    assert_difference('Notification.count') do
      @call_for_participation.notification = FactoryGirl.create(:notification)
      put :update, call_for_participations: @call_for_participation.attributes, conference_acronym: @conference.acronym
    end
  end

end

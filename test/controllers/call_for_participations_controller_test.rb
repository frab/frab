require 'test_helper'

class CallForParticipationsControllerTest < ActionController::TestCase
  setup do
    @call_for_participation = FactoryGirl.create(:call_for_participation)
    @conference = @call_for_participation.conference
    login_as(:admin)
  end

  def call_for_participation_params
    {
      start_date: Date.today.ago(1.days).strftime('%Y-%m-%d'),
      end_date: Date.today.since(6.days).strftime('%Y-%m-%d')
    }
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
    params = {
      call_for_participation: call_for_participation_params,
      conference_acronym: new_conference.acronym
    }
    assert_difference('CallForParticipation.count') do
      post :create, params
    end
  end

  test "should get edit" do
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update cfp" do
    params = {
      call_for_participation: call_for_participation_params.merge(welcome_text: "welcome"),
      conference_acronym: @conference.acronym
    }
    put :update, params
    assert_redirected_to call_for_participation_path(conference_acronym: @conference.acronym)
  end
end

require 'test_helper'

class ConferencesControllerTest < ActionController::TestCase
  setup do
    FactoryGirl.create(:conference)
    FactoryGirl.create(:conference)
    @conference = FactoryGirl.create(:conference)
    login_as(:admin)
  end

  test "should list all" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conference" do
    assert_difference('Conference.count') do
      post :create, conference: FactoryGirl.build(:conference).attributes
    end
  end

  test "should get edit" do
    get :edit, id: @conference.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update conference" do
    new_acronym = @conference.acronym + "1"
    put :update, id: @conference.to_param, conference: @conference.attributes.merge(acronym: new_acronym), conference_acronym: @conference.acronym
    assert_redirected_to edit_conference_path(conference_acronym: new_acronym)
  end

  test "should get edit days" do
    get :edit_days, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should add conference_day" do
    assert_difference('Day.count') do
      @conference.days << FactoryGirl.create(:day)
      put :update, conference: @conference.attributes, conference_acronym: @conference.acronym
    end
  end

  test "should create conference with feedback disabled" do
    assert_difference('Conference.count') do
      post :create, conference: FactoryGirl.build(:conference, feedback_enabled: false).attributes
    end
  end

end

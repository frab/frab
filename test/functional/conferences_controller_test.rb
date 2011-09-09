require 'test_helper'

class ConferencesControllerTest < ActionController::TestCase
  setup do
    @conference = FactoryGirl.create(:conference)
    login_as(:admin)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conference" do
    assert_difference('Conference.count') do
      post :create, :conference => FactoryGirl.build(:conference).attributes
    end
  end

  test "should get edit" do
    get :edit, :id => @conference.to_param, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should update conference" do
    @request.env["HTTP_REFERER"] = "http://localhost/"
    put :update, :id => @conference.to_param, :conference => @conference.attributes, :conference_acronym => @conference.acronym
    assert_redirected_to "http://localhost/" 
  end

end

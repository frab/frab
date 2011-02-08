require 'test_helper'

class ConferencesControllerTest < ActionController::TestCase
  setup do
    @conference = conferences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:conferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conference" do
    assert_difference('Conference.count') do
      post :create, :conference => @conference.attributes
    end

    assert_redirected_to conference_path(assigns(:conference))
  end

  test "should show conference" do
    get :show, :id => @conference.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @conference.to_param
    assert_response :success
  end

  test "should update conference" do
    put :update, :id => @conference.to_param, :conference => @conference.attributes
    assert_redirected_to conference_path(assigns(:conference))
  end

  test "should destroy conference" do
    assert_difference('Conference.count', -1) do
      delete :destroy, :id => @conference.to_param
    end

    assert_redirected_to conferences_path
  end
end

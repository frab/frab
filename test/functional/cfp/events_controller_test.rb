require 'test_helper'

class Cfp::EventsControllerTest < ActionController::TestCase
  setup do
    @cfp_event = cfp_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cfp_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cfp_event" do
    assert_difference('Cfp::Event.count') do
      post :create, :cfp_event => @cfp_event.attributes
    end

    assert_redirected_to cfp_event_path(assigns(:cfp_event))
  end

  test "should show cfp_event" do
    get :show, :id => @cfp_event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cfp_event.to_param
    assert_response :success
  end

  test "should update cfp_event" do
    put :update, :id => @cfp_event.to_param, :cfp_event => @cfp_event.attributes
    assert_redirected_to cfp_event_path(assigns(:cfp_event))
  end

  test "should destroy cfp_event" do
    assert_difference('Cfp::Event.count', -1) do
      delete :destroy, :id => @cfp_event.to_param
    end

    assert_redirected_to cfp_events_path
  end
end

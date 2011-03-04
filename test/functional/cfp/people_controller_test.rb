require 'test_helper'

class Cfp::PeopleControllerTest < ActionController::TestCase
  setup do
    @cfp_person = cfp_people(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cfp_people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cfp_person" do
    assert_difference('Cfp::Person.count') do
      post :create, :cfp_person => @cfp_person.attributes
    end

    assert_redirected_to cfp_person_path(assigns(:cfp_person))
  end

  test "should show cfp_person" do
    get :show, :id => @cfp_person.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cfp_person.to_param
    assert_response :success
  end

  test "should update cfp_person" do
    put :update, :id => @cfp_person.to_param, :cfp_person => @cfp_person.attributes
    assert_redirected_to cfp_person_path(assigns(:cfp_person))
  end

  test "should destroy cfp_person" do
    assert_difference('Cfp::Person.count', -1) do
      delete :destroy, :id => @cfp_person.to_param
    end

    assert_redirected_to cfp_people_path
  end
end

require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @person = people(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      post :create, :person => @person.attributes
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "should show person" do
    get :show, :id => @person.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @person.to_param
    assert_response :success
  end

  test "should update person" do
    put :update, :id => @person.to_param, :person => @person.attributes
    assert_redirected_to person_path(assigns(:person))
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, :id => @person.to_param
    end

    assert_redirected_to people_path
  end
end

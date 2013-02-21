require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @person = FactoryGirl.create(:person)
    @conference = FactoryGirl.create(:conference)
    login_as(:admin)
  end

  test "should get index" do
    get :index, conference_acronym: @conference.acronym
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should get new" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      post :create, person: @person.attributes, conference_acronym: @conference.acronym
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "should show person" do
    get :show, id: @person.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @person.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update person" do
    put :update, id: @person.to_param, person: @person.attributes, conference_acronym: @conference.acronym
    assert_redirected_to person_path(assigns(:person))
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, id: @person.to_param, conference_acronym: @conference.acronym
    end

    assert_redirected_to people_path
  end
end

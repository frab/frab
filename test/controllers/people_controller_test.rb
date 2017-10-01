require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @person = create(:person)
    @conference = create(:three_day_conference_with_events_and_speakers)
    login_as(:admin)
  end

  def person_params
    @person.attributes.except('id', 'avatar_content_type', 'avatar_file_size', 'avatar_updated_at', 'avatar_file_name', 'created_at', 'updated_at', 'user_id')
  end

  test 'should get index' do
    get :index, params: { conference_acronym: @conference.acronym }
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test 'should get new' do
    get :new, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should create person' do
    assert_difference('Person.count') do
      post :create, params: { person: person_params, conference_acronym: @conference.acronym }
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test 'should show person' do
    get :show, params: { id: @person.to_param, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @person.to_param, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update person' do
    put :update, params: { id: @person.to_param, person: person_params, conference_acronym: @conference.acronym }
    assert_redirected_to person_path(assigns(:person))
  end

  test 'should destroy person' do
    assert_difference('Person.count', -1) do
      delete :destroy, params: { id: @person.to_param, conference_acronym: @conference.acronym }
    end

    assert_redirected_to people_path
  end

  test 'should get index as JSON' do
    get :index, format: :json, params: { conference_acronym: @conference.acronym }
    assert_response :success
    people = JSON.parse(response.body)['people']
    assert_equal 3, people.count
    assert_includes people[0].keys, 'full_public_name'
    assert_includes people[0].keys, 'links'
  end

  test 'should show person as JSON' do
    get :show, format: :json, params: { id: @person.to_param, conference_acronym: @conference.acronym }
    assert_response :success
    person = JSON.parse(response.body)
    assert_includes person.keys, 'full_public_name'
    assert_includes person.keys, 'links'
  end
end

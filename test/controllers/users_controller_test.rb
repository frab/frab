require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @conference = create(:conference)
    @person = create(:person)
    @user = create(:user, person: create(:person))
    login_as(:admin)
  end

  def user_params(user_type = :user)
    user_params = attributes_for(user_type).merge(password: 'frab123', password_confirmation: 'frab123')
    user_params.delete(:confirmed_at)
    user_params.delete(:sign_in_count)
    user_params
  end

  test 'should get new' do
    get :new, params: { person_id: @person.id, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should create user' do
    assert_difference('User.count') do
      post :create, params: { user: user_params, person_id: @person.id, conference_acronym: @conference.acronym }
    end

    assert_redirected_to edit_person_user_path(@person)
  end

  test 'should get edit' do
    get :edit, params: { person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update user' do
    put :update, params: { user: { id: @user.id, email: 'admin@example.org' }, person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_redirected_to edit_crew_user_path(@user.person)
    get :edit, params: { person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update user password' do
    put :update, params: { user: { id: @user.id, password: 'test123', password_confirmation: 'test123' }, person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_redirected_to edit_crew_user_path(@user.person)
    get :edit, params: { person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should create crew user' do
    assert_difference('User.count') do
      post :create, params: {
        user: user_params(:crew_user),
        person_id: @person.id,
        conference_acronym: @conference.acronym
      }
    end
  end

  test 'should change users role' do
    @user.role = 'crew'
    put :update, params: { user: { id: @user.id, role: 'crew' }, person_id: @user.person.id, conference_acronym: @conference.acronym }
    @user.reload
    assert_equal 'crew', @user.role
  end

  test 'should add conference user to existing crew user' do
    @user = create(:crew_user, person: create(:person))
    user_attributes = { id: @user.id, role: 'crew' }
    user_attributes['conference_users_attributes'] = {
      '0' => attributes_for(:conference_user, role: 'reviewer', conference_id: @conference.id)
    }
    assert_difference('ConferenceUser.count') do
      put :update, params: {
        user: user_attributes,
        person_id: @user.person.id,
        conference_acronym: @conference.acronym
      }
    end
    assert_redirected_to edit_crew_user_path(@user.person)
  end
end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @conference = FactoryGirl.create(:conference)
    @person = FactoryGirl.create(:person)
    @user = FactoryGirl.create(:user, person: FactoryGirl.create(:person))
    login_as(:admin)
  end

  test "should get new" do
    get :new, person_id: @person.id, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: FactoryGirl.build(:user).attributes.merge(password: "frab123", password_confirmation: "frab123"), person_id: @person.id, conference_acronym: @conference.acronym
    end

    assert_redirected_to person_user_path(@person)
  end

  test "should get edit" do
    get :edit, id: @user.to_param, person_id: @user.person.id, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user.to_param, user: @user.attributes, person_id: @user.person.id, conference_acronym: @conference.acronym
    assert_redirected_to person_user_path(@user.person)
  end

end

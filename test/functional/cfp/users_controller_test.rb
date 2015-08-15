require 'test_helper'

class Cfp::UsersControllerTest < ActionController::TestCase

  setup do
    @call_for_papers = FactoryGirl.create(:call_for_papers)
    @conference = @call_for_papers.conference
  end

  test "shows registration form" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "allows registration of new user" do
    assert_difference 'User.count' do
      post :create, conference_acronym: @conference.acronym, user: {email: "new_user@example.com", password: "frab123", password_confirmation: "frab123"}
    end
    assert_response :redirect
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:user).confirmation_token
  end

  test "shows password editing form" do
    login_as(:submitter)
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "allows editing of password" do
    user = login_as(:submitter)
    digest_before = user.password_digest
    put :update, conference_acronym: @conference.acronym, user: {password: "123frab", password_confirmation: "123frab"}
    assert_response :redirect
    user.reload
    assert_not_equal digest_before, user.password_digest
  end

end

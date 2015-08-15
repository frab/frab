require 'test_helper'

class Cfp::PasswordsControllerTest < ActionController::TestCase

  setup do
    @call_for_papers = FactoryGirl.create(:call_for_papers)
    @conference = @call_for_papers.conference
  end

  test "displays password reset request form" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "sends password reset instructions" do
    user = FactoryGirl.create(:user)
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, conference_acronym: @conference.acronym, user: {email: user.email}
    end
    assert_response :redirect
    user.reload
    assert_not_nil user.reset_password_token
  end

  test "displays password reset form" do
    user = FactoryGirl.create(:user)
    user.send_password_reset_instructions(@call_for_papers.conference)
    get :edit, conference_acronym: @conference.acronym, reset_password_token: user.reset_password_token
    assert_response :success
  end

  test "allows setting a new password" do
    user = FactoryGirl.create(:user)
    user.send_password_reset_instructions(@call_for_papers.conference)
    before_digest = user.password_digest
    put :update, conference_acronym: @conference.acronym, user: {reset_password_token: user.reset_password_token, password: "123frab", password_confirmation: "123frab"}
    assert_response :redirect
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:current_user)
    assert_nil assigns(:user).reset_password_token
    assert_not_equal before_digest, assigns(:user).password_digest
  end

end

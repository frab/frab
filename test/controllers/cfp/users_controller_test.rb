require 'test_helper'

class Cfp::UsersControllerTest < ActionController::TestCase
  setup do
    @call_for_participation = create(:call_for_participation)
    @conference = @call_for_participation.conference
    @user = login_as(:submitter)
  end

  test 'shows password editing form' do
    get :edit, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'allows editing of password' do
    @password = @user.encrypted_password
    put :update, params: { conference_acronym: @conference.acronym, user: { password: '123frab', password_confirmation: '123frab' } }
    assert_response :redirect
    refute_equal @password, @user.reload.encrypted_password
  end

  test 'should update user email only' do
    put :update, params: { conference_acronym: @conference.acronym, user: { email: 'new@example.org' } }
    assert_response :redirect
    assert_equal 'new@example.org', @user.reload.unconfirmed_email
  end
end

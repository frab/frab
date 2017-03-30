require 'test_helper'

class Cfp::UsersControllerTest < ActionController::TestCase
  setup do
    @call_for_participation = create(:call_for_participation)
    @conference = @call_for_participation.conference
  end

  test 'shows password editing form' do
    login_as(:submitter)
    get :edit, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'allows editing of password' do
    login_as(:submitter)
    put :update, params: { conference_acronym: @conference.acronym, user: { password: '123frab', password_confirmation: '123frab' } }
    assert_response :redirect
  end
end

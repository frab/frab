require 'test_helper'

class Cfp::SessionsControllerTest < ActionController::TestCase
  setup do
    @first_conference = create(:conference)
    create(:call_for_participation, conference: @first_conference)

    @conference = create(:conference)
    @call_for_participation = create(:call_for_participation, conference: @conference)

    @last_conference = create(:conference)
    create(:call_for_participation, conference: @last_conference)

    @submitter = create(:user, password: 'frab123', password_confirmation: 'frab123', role: 'submitter')
  end

  test 'submitter can login' do
    post :create, conference_acronym: @conference.acronym, user: { email: @submitter.email, password: 'frab123' }
    assert_not_nil assigns(:current_user)
    assert_response :redirect
  end

  test 'nonexistent user cannot login' do
    post :create, conference_acronym: @conference.acronym, user: { email: 'not@exista.nt', password: 'frab123' }
    assert_nil assigns(:current_user)
    assert_response :success
  end

  test 'cannot login with wrong password' do
    post :create, conference_acronym: @conference.acronym, user: { email: @submitter.email, password: 'wrong' }
    assert_nil assigns(:current_user)
    assert_response :success
  end

  test 'submitter redirects to conference specified as parameter after login' do
    post :create, conference_acronym: @conference.acronym, user: { email: @submitter.email, password: 'frab123' }
    assert_redirected_to cfp_person_path, conference_acronym: @conference.acronym
  end

  test 'submitter redirects to conference specified in session after login' do
    session[:conference_acronym] = @first_conference.acronym
    post :create, conference_acronym: @conference.acronym, user: { email: @submitter.email, password: 'frab123' }
    assert_redirected_to cfp_person_path, conference_acronym: @first_conference.acronym
  end

  # test "submitter gets  no redirect if parameter/session are absent on login" do
  # end
end

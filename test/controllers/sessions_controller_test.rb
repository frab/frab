require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @first_conference = FactoryGirl.create(:conference)
    @conference = FactoryGirl.create(:conference)
    @last_conference = FactoryGirl.create(:conference)
    @orga = FactoryGirl.create(:user, password: 'frab123', password_confirmation: 'frab123', role: 'orga')
    @submitter = FactoryGirl.create(:user, password: 'frab123', password_confirmation: 'frab123', role: 'submitter')
  end

  test 'admin user can login' do
    post :create, conference_acronym: @conference.acronym, user: user_param(@orga)
    assert_not_nil assigns(:current_user)
    assert_response :redirect
  end

  test 'submitter gets redirected to cfp area after login' do
    post :create, conference_acronym: @conference.acronym, user: user_param(@submitter)
    assert_redirected_to cfp_person_path(conference_acronym: @conference.acronym)
  end

  test 'submitter gets redirected to cfp area from session after login' do
    session[:conference_acronym] = @first_conference.acronym
    post :create, user: user_param(@submitter)
    assert_redirected_to cfp_person_path(conference_acronym: @first_conference.acronym)
  end

  test 'nonexistant user cannot login' do
    post :create, conference_acronym: @conference.acronym, user: { email: 'not@exista.nt', password: 'frab123' }
    assert_nil assigns(:current_user)
    assert_response :success
  end

  test 'unconfirmed user cannot login' do
    user = FactoryGirl.create(:user, password: 'frab123', password_confirmation: 'frab123', role: 'orga')
    user.confirmed_at = nil
    user.save!
    post :create, conference_acronym: @conference.acronym, user: user_param(user)
    assert_response :success
    assert_nil assigns(:current_user)
  end

  test 'cannot login with wrong password' do
    post :create, conference_acronym: @conference.acronym, user: user_param(@orga, 'wrong')
    assert_nil assigns(:current_user)
    assert_response :success
  end

  test 'orga login works with conference as parameter' do
    post :create, user: user_param(@orga), conference_acronym: @conference.acronym
    assert_redirected_to root_path, conference_acronym: @conference.acronym
  end

  test 'orga login works with conference acronym from session' do
    session[:conference_acronym] = @conference.acronym
    post :create, user: user_param(@orga)
    assert_redirected_to root_path, conference_acronym: @conference.acronym
  end

  test 'conference parameter takes precedence on team login' do
    session[:conference_acronym] = @first_conference.acronym
    post :create, conference_acronym: @conference.acronym, user: user_param(@orga)
    assert_redirected_to root_path, conference_acronym: @conference.acronym
  end

  test 'current conference choosen if session and parameter are absent' do
    post :create, user: user_param(@orga)
    assert_redirected_to root_path, conference_acronym: @last_conference.acronym
  end

  test 'login page works if no conferences are known' do
    Conference.all.each(&:destroy)
    get :new
    assert_response :success
  end

  test 'does not return error code if parameters are missing' do
    post :create, whatever: 'foooo'
    assert_nil assigns(:current_user)
    assert_response :success
  end

  private

  def user_param(user, password = 'frab123')
    { email: user.email, password: password }
  end
end

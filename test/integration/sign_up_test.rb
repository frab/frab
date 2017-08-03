require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference, title: 'present conference')
    create(:call_for_participation, conference: @conference)
  end

  test 'can sign up for cfp and get redirected to cfp page' do
    get '/'
    assert_includes @response.body, '<title>frab - home'
    assert_includes @response.body, @conference.title
    get "/#{@conference.acronym}/cfp"
    assert_includes @response.body, "<title>\n#{@conference.title}"
    assert_includes @response.body, "#{@conference.title}\n- Call for Participation"

    post '/users', params: {
      'user' => { 'email' => 'test2@example.org', 'password' => 'frab12345', 'password_confirmation' => 'frab12345' },
      'commit' => 'Sign up', 'conference_acronym' => @conference.acronym, 'locale' => 'en'
    }
    follow_redirect!
    assert_includes @response.body, 'confirmation link'
    assert_includes @response.body, "#{@conference.title}\n- Call for Participation"

    user = User.last
    user.confirm

    post '/users/sign_in', params: {
      'user' => { 'email' => 'test2@example.org', 'password' => 'frab12345' },
      'commit' => 'Log in', 'locale' => 'en'
    }
    follow_redirect!
    assert_includes @response.body, "#{@conference.title}\n- Call for Participation"
    assert_includes @response.body, 'Update profile'
  end

  test 'can sign in and get redirected to cfp page' do
    user = create(:user)
    get "/#{@conference.acronym}/cfp"
    post '/users/sign_in', params: {
      'user' => { 'email' => user.email, 'password' => user.password },
      'commit' => 'Log in', 'locale' => 'en'
    }
    follow_redirect!
    assert_includes @response.body, "#{@conference.title}\n- Call for Participation"
    assert_includes @response.body, 'Update profile'
  end

  test 'can sign in and get redirected back to root if no recent conference' do
    get '/'
    user = create(:user)
    post '/users/sign_in', params: {
      'user' => { 'email' => user.email, 'password' => user.password },
      'commit' => 'Log in', 'locale' => 'en'
    }
    follow_redirect!
    assert_select 'li', 'Current Conferences'
  end

  test 'crew can sign in and gets redirected right' do
    user = create(:admin_user)
    get "/#{@conference.acronym}/cfp"
    post '/users/sign_in', params: {
      'user' => { 'email' => user.email, 'password' => user.password },
      'commit' => 'Log in', 'locale' => 'en'
    }
    follow_redirect!
    assert_includes @response.body, 'Recent changes'
  end
end

require 'test_helper'

class LdapTest < FeatureTest
  LOGIN='tesla'     # see https://www.forumsys.com/category/tutorials/integration-how-to/
  PASSWORD='password'
  EMAIL='tesla@ldap.forumsys.com'

  setup do
    assert User.where(email: EMAIL).blank?
  end

  def connect_with_ldap(login, pwd)
    visit '/'
   
    click_on 'Log-in'
   
    click_on 'Sign in with free testing server at ldap.forumsys.com'
   
    fill_in 'Login:', with: login
    fill_in 'Password:', with: pwd
    click_on 'Sign In'
   
    assert_content page, 'Successfully authenticated'
    assert User.where(email: EMAIL).any?
    
    click_on 'Logout'
  end

  test 'can sign up and sign in with LDAP' do
    connect_with_ldap(LOGIN,PASSWORD) # for new user
    connect_with_ldap(LOGIN,PASSWORD) # for existing user
    connect_with_ldap(EMAIL,PASSWORD) # using e-mail instead of login field
  end

  test 'rejects wrong password' do
    visit '/'
   
    click_on 'Log-in'
   
    click_on 'Sign in with free testing server at ldap.forumsys.com'
   
    fill_in 'Login:', with: 'wrong'
    fill_in 'Password:', with: 'wrong'
    click_on 'Sign In'
   
    assert_content page, 'Authentication failed'
  end
  
  teardown do
    User.where(email: EMAIL).destroy_all
  end
end

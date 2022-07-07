require 'application_system_test_case'

# TODO This test uses a remote service and is flaky.
# Fails with: `Authentication failure! ldap_error: Net::LDAP::Error, Connection
# timed out - user specified timeout`
class LdapTest < ApplicationSystemTestCase
  LOGIN='tesla'     # see https://www.forumsys.com/category/tutorials/integration-how-to/
  PASSWORD='password'
  EMAIL='tesla@ldap.forumsys.com'

  setup do
    assert User.where(email: EMAIL).blank?
  end

  def connect_with_ldap(login, pass)
    visit '/'

    click_on 'Log-in'

    click_on 'Sign in with free testing server at ldap.forumsys.com'

    fill_in 'Login:', with: login
    fill_in 'Password:', with: pass
    click_on 'Sign In'

    assert_content page, 'Successfully authenticated'
    assert User.where(email: EMAIL).any?

    sign_out
  end

  test 'can sign up and sign in with LDAP' do
    skip('ldap.forumsys.com is not reachable')
    connect_with_ldap(LOGIN, PASSWORD) # for new user
    connect_with_ldap(LOGIN, PASSWORD) # for existing user
    connect_with_ldap(EMAIL, PASSWORD) # using e-mail instead of login field
  end

  test 'rejects wrong password' do
    skip('ldap.forumsys.com is not reachable')
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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'logins can be recorded' do
    user = FactoryGirl.create(:user)
    assert_equal 0, user.sign_in_count
    assert_nil user.last_sign_in_at
    user.record_login!
    user.reload
    assert_equal 1, user.sign_in_count
    assert_not_nil user.last_sign_in_at
  end

  test 'create admin user' do
    user = FactoryGirl.create(:admin_user)
    assert_equal 'admin', user.role
  end

  test 'create crew user' do
    user = FactoryGirl.create(:crew_user)
    assert_equal 'crew', user.role
  end
end

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'logins can be recorded' do
    user = create(:user)
    assert user.valid?
    assert_equal 0, user.sign_in_count
    assert_nil user.last_sign_in_at
  end

  test 'create admin user' do
    user = create(:admin_user)
    assert_equal 'admin', user.role
  end

  test 'create crew user' do
    user = create(:crew_user)
    assert_equal 'crew', user.role
  end
end

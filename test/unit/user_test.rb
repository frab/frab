require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "logins can be recorded" do
    user = FactoryGirl.create(:user)
    assert_equal 0, user.sign_in_count
    assert_nil user.last_sign_in_at
    user.record_login!
    user.reload
    assert_equal 1, user.sign_in_count
    assert_not_nil user.last_sign_in_at
  end

  test "create admin user" do
    user = FactoryGirl.create(:admin_user)
    assert_equal "admin", user.role
  end

  test "create orga user" do
    user = FactoryGirl.create(:orga_user)
    assert_equal "orga", user.role
  end

  test "create coordinator user" do
    user = FactoryGirl.create(:coordinator_user)
    assert_equal "coordinator", user.role
  end

  test "create reviewer user" do
    user = FactoryGirl.create(:reviewer_user)
    assert_equal "reviewer", user.role
  end

  test "create submitter user" do
    user = FactoryGirl.create(:user)
    assert_equal "submitter", user.role
  end
end

require 'test_helper'

class ConferenceUserTest < ActiveSupport::TestCase
  test 'create orga user' do
    cu = create(:conference_orga)
    assert_equal 1, cu.user.conference_users.size
    assert_equal 'crew', cu.user.role
    assert_equal 'orga', cu.role
  end

  test 'create coordinator user' do
    cu = create(:conference_coordinator)
    assert_equal 1, cu.user.conference_users.size
    assert_equal 'crew', cu.user.role
    assert_equal 'coordinator', cu.role
  end

  test 'create reviewer user' do
    cu = create(:conference_reviewer)
    assert_equal 1, cu.user.conference_users.size
    assert_equal 'crew', cu.user.role
    assert_equal 'reviewer', cu.role
  end

  test 'cannot save conference user without role' do
    cu = create(:conference_orga)
    cu.role = nil
    assert_equal false, cu.valid?
  end
end

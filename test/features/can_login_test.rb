require 'test_helper'

class CanLoginTest < FeatureTest
  setup do
    @admin = create(:admin_user)
  end

  test 'sanity' do
    sign_in_user(@admin)
    assert_content page, 'Create new conference'
  end
end

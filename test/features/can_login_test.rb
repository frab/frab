require 'test_helper'

class CanLoginTest < FeatureTest
  setup do
    @admin = create(:admin_user)
  end

  test 'admin can log in' do
    sign_in_user(@admin)
    assert_content page, 'Create new conference'
  end

  test 'submitter can log in' do
    @user = create(:cfp_user)
    sign_in_user(@user)
    assert_content page, 'Signed in successfully'
  end
end

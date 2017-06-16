require 'test_helper'

class ConferenceUsersControllerTest < ActionController::TestCase
  setup do
    @conference_user = create(:conference_orga)
    create(:conference_coordinator)
    create(:conference_reviewer)
    login_as(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get destroy' do
    delete :destroy, params: { id: @conference_user }
    assert_response :redirect
    assert_equal 2, ConferenceUser.count
  end
end

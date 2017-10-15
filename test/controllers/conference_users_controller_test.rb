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

  test 'should get admins' do
    get :admins
    assert_response :success
  end
end

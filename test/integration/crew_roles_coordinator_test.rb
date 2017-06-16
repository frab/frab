require 'test_helper'

class CrewRolesCoordinatorTest < PunditControllerTest
  include SharedCrewRolesTest
  include SharedManagerRolesTest

  setup do
    @acronym = create_conference
    create_other_conference
    @user = create(:conference_coordinator, conference: @conference).user
    sign_in(@user)
  end

  def test_coordinator_access
    get "/#{@acronym}"
    assert_response :success
    get "/#{@acronym}/conference/edit"
    assert_ability_denied
    get '/conferences/new'
    assert_ability_denied

    get "/#{@acronym}/people/#{@submitter_user.person.id}/user"
    assert_ability_denied
  end
end

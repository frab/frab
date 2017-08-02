require 'test_helper'

class CrewRolesOrgaTest < PunditControllerTest
  include SharedCrewRolesTest
  include SharedManagerRolesTest

  setup do
    @acronym = create_conference
    create_other_conference
    @user = create(:conference_orga, conference: @conference).user
    sign_in(@user)
  end

  def test_xx
    get "/#{@acronym}/people/#{@submitter_user.person.id}"
    assert_response :success
  end

  def test_orga_access
    # TODO should list actions (show/edit) in crew index correctly
    get "/#{@acronym}"
    assert_response :success
    get "/#{@acronym}/conference/edit"
    assert_response :success
    get '/conferences/new'
    assert_response :success
    # TODO test nested conference, ticket_server, default_notifications

    get "/#{@acronym}/people/#{@submitter_user.person.id}/user"
    assert_response :success

    get "/#{@acronym}/people/#{@submitter_user.person.id}"
    assert_response :success

    get "/user/#{@submitter_user.person.id}/edit"
    assert_response :success
    # TODO test: cannot modify admin user
    # TODO test: can only assign roles on own orga conferences
  end
end

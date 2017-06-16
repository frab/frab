require 'test_helper'

class CrewRolesReviewerTest < PunditControllerTest
  include SharedCrewRolesTest

  setup do
    @acronym = create_conference
    create_other_conference
    @user = create(:conference_reviewer, conference: @conference).user
    sign_in(@user)
  end

  def test_reviewer_access
    get "/#{@acronym}"
    assert_response :success
    get "/#{@acronym}/conference/edit"
    assert_ability_denied
    get '/conferences/new'
    assert_ability_denied

    get "/#{@acronym}/call_for_participation"
    assert_response :success

    get "/#{@acronym}/events/#{@event.id}"
    assert_response :success
    get "/#{@acronym}/events/#{@event.id}/edit"
    assert_ability_denied
    patch "/#{@acronym}/events/#{@event.id}", params: { event: { title: 'changed' } }
    assert_ability_denied

    get "/#{@acronym}/people/#{@submitter_user.person.id}"
    assert_response :success

    get "/user/#{@submitter_user.person.id}/edit"
    assert_ability_denied
    get "/#{@acronym}/people/#{@submitter_user.person.id}/user"
    assert_ability_denied
  end
end

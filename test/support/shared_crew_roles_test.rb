module SharedCrewRolesTest
  def test_manage_own_user
    get "/people/#{@user.person.id}/user"
    assert_response :success
    get "/people/#{@user.person.id}/user/edit"
    assert_response :success
  end

  def test_event_rating_permissions
    get "/#{@acronym}/events/#{@event.id}/event_rating"
    assert_response :success
    post "/#{@acronym}/events/#{@event.id}/event_rating", params: { event_rating: { rating: '4' } }
    assert_redirected_to event_event_rating_path

    get "/#{@other_conference.acronym}/events/#{@other_event.id}/event_rating"
    assert_ability_denied
  end

  def test_refute_access_to_other_conference
    acronym = @other_conference.acronym
    get "/#{acronym}"
    assert_ability_denied
    get "/#{acronym}/conference/edit"
    assert_ability_denied
  end

  def test_refute_access_to_other_event
    acronym = @other_conference.acronym
    get "/#{acronym}/events/#{@other_event.id}"
    assert_ability_denied
    get "/#{acronym}/events/#{@other_event.id}/edit"
    assert_ability_denied
    patch "/#{acronym}/events/#{@other_event.id}", params: { event: { title: 'changed' } }
    assert_ability_denied
  end

  def test_manage_own_person
    get "/people/#{@user.person.id}", params: { conference_acronym: @acronym }
    assert_response :success
    get "/#{@acronym}/cfp/person/edit"
    assert_response :success
    # TODO bug: switches to cfp interface and hides navi
    # TODO bug: not reachable with wrong conference
    # get "/#{@other_conference.acronym}/cfp/person/edit"
  end
end

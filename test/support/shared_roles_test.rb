module SharedManagerRolesTest
  def test_manage_cfp
    get "/#{@acronym}/call_for_participation/new"
    assert_response :success
    get "/#{@acronym}/call_for_participation/edit"
    assert_response :success
  end

  def test_manage_event
    get "/#{@acronym}/events/#{@event.id}"
    assert_response :success
    get "/#{@acronym}/events/#{@event.id}/edit"
    assert_response :success
    patch "/#{@acronym}/events/#{@event.id}", params: { event: { title: 'changed' } }
    assert_redirected_to event_path
  end

  # TODO limit access to people not involved in conference, currently allows all people
  def test_manage_other_person
    get "/#{@acronym}/people/#{@submitter_user.person.id}"
    assert_response :success
    get "/#{@acronym}/people/#{@submitter_user.person.id}/edit"
    assert_response :success
    patch "/#{@acronym}/people/#{@submitter_user.person.id}", params: { person: { first_name: 'test' } }
    assert_redirected_to person_path
  end
end

require 'test_helper'

class Cfp::PeopleControllerTest < ActionController::TestCase
  setup do
    @cfp_person = create(:person)
    @call_for_participation = create(:call_for_participation)
    @conference = @call_for_participation.conference
    login_as(:submitter)
  end

  def cfp_person_params
    @cfp_person.attributes.except('id', 'avatar_file_name', 'avatar_content_type', 'avatar_file_size', 'avatar_updated_at', 'created_at', 'updated_at', 'user_id', 'note')
  end

  test 'should get edit' do
    get :edit, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update cfp_person' do
    put :update, params: { id: @cfp_person.id, person: cfp_person_params, conference_acronym: @conference.acronym }
    assert_response :redirect
  end
end

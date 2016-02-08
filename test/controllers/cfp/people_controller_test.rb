require 'test_helper'

class Cfp::PeopleControllerTest < ActionController::TestCase
  setup do
    @cfp_person = FactoryGirl.create(:person)
    @call_for_participation = FactoryGirl.create(:call_for_participation)
    @conference = @call_for_participation.conference
    login_as(:submitter)
  end

  def cfp_person_params
    @cfp_person.attributes.except(*%w(id avatar_file_name avatar_content_type avatar_file_size avatar_updated_at created_at updated_at user_id note))
  end

  test 'should get new' do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should create cfp_person' do
    # can't have two persons on one user, so delete the one from login_as
    user = FactoryGirl.create(
      :user,
      role: 'submitter'
    )
    user.person = nil
    session[:user_id] = user.id

    assert_difference 'Person.count' do
      post :create, person: { email: @cfp_person.email,
                              public_name: @cfp_person.public_name },
                    conference_acronym: @conference.acronym
    end
    assert_response :redirect
  end

  test 'should get edit' do
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should update cfp_person' do
    put :update, id: @cfp_person.id, person: cfp_person_params, conference_acronym: @conference.acronym
    assert_response :redirect
  end
end

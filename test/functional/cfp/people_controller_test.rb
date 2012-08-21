require 'test_helper'

class Cfp::PeopleControllerTest < ActionController::TestCase
  setup do
    @cfp_person = FactoryGirl.create(:person)
    @conference = FactoryGirl.create(:conference)
    login_as(:submitter)
  end

  test "should get new" do
    get :new, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should create cfp_person" do
    assert_difference 'Person.count' do
      post :create, :person => {:email => @cfp_person.email, 
                    :public_name => @cfp_person.public_name}, 
                    :conference_acronym => @conference.acronym
    end

    assert_response :redirect
  end

  test "should get edit" do
    get :edit, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should update cfp_person" do
    put :update, :id => @cfp_person.id, :person => @cfp_person.attributes, :conference_acronym => @conference.acronym
    assert_response :redirect
  end

end

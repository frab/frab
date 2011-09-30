require 'test_helper'

class Cfp::SessionsControllerTest < ActionController::TestCase

  setup do
    @conference = FactoryGirl.create(:conference)
    @call_for_papers = FactoryGirl.create(:call_for_papers, :conference => @conference)
    request.env["devise.mapping"] = Devise.mappings[:cfp_user]
  end

  test "submitter can login" do
    user = FactoryGirl.create(:user, :password => "frab123", :password_confirmation => "frab123", :role => "submitter")
    post :create, :conference_acronym => @conference.acronym, :cfp_user => {:email => user.email, :password => "frab123"}
    assert_not_nil assigns(:current_cfp_user)
    assert_response :redirect
  end

  test "non-existant user cannot login" do
    post :create, :conference_acronym => @conference.acronym, :cfp_user => {:email => "not@exista.nt", :password => "frab123"}
    assert_nil assigns(:current_cfp_user)
    assert_response :success
  end

  test "cannot login with wrong password" do
    user = FactoryGirl.create(:user, :password => "frab123", :password_confirmation => "frab123", :role => "submitter")
    post :create, :conference_acronym => @conference.acronym, :cfp_user => {:email => user.email, :password => "wrong"}
    assert_nil assigns(:current_cfp_user)
    assert_response :success
  end

end

require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  setup do
    @conference = FactoryGirl.create(:conference)
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "admin user can login" do
    user = FactoryGirl.create(:user, :password => "frab123", :password_confirmation => "frab123", :role => "admin")
    post :create, :conference_acronym => @conference.acronym, :user => {:email => user.email, :password => "frab123"}
    assert_not_nil assigns(:current_user)
    assert_response :redirect
  end

  test "submitter gets redirected to cfp area after login" do
    user = FactoryGirl.create(:user, :password => "frab123", :password_confirmation => "frab123", :role => "submitter")
    post :create, :conference_acronym => @conference.acronym, :user => {:email => user.email, :password => "frab123"}
    assert_redirected_to cfp_root_path(:conference_acronym => @conference.acronym)
  end

  test "non-existant user cannot login" do
    post :create, :conference_acronym => @conference.acronym, :user => {:email => "not@exista.nt", :password => "frab123"}
    assert_nil assigns(:current_user)
    assert_response :success
  end

  test "cannot login with wrong password" do
    user = FactoryGirl.create(:user, :password => "frab123", :password_confirmation => "frab123", :role => "admin")
    post :create, :conference_acronym => @conference.acronym, :user => {:email => user.email, :password => "wrong"}
    assert_nil assigns(:current_user)
    assert_response :success
  end

end

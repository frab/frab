require 'test_helper'

class Cfp::ConfirmationsControllerTest < ActionController::TestCase
  
  setup do
    @call_for_participation = FactoryGirl.create(:call_for_participation)
    @conference = @call_for_participation.conference
  end

  test "displays resend confirmation instructions form" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "resends confirmation instructions" do
    user = FactoryGirl.create(:user, confirmed_at: nil, call_for_participation: @call_for_participation)
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, conference_acronym: @conference.acronym, user: {email: user.email}
    end
    assert_response :redirect
  end

  test "performs confirmation" do
    user = FactoryGirl.create(:user, confirmed_at: nil, call_for_participation: @call_for_participation)
    get :show, conference_acronym: @conference.acronym, confirmation_token: user.confirmation_token 
    assert_response :redirect
    assert_not_nil assigns(:current_user)
    user.reload
    assert_not_nil user.confirmed_at
    assert_nil user.confirmation_token
  end

end

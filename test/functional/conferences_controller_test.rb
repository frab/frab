require 'test_helper'

class ConferencesControllerTest < ActionController::TestCase
  setup do
    FactoryGirl.create(:conference)
    FactoryGirl.create(:conference)
    @conference = FactoryGirl.create(:conference)
    login_as(:admin)
  end

  def conference_params
    @conference.attributes.except(*%w(id created_at updated_at))
  end

  test "should list all" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conference" do
    assert_difference('Conference.count') do
      post :create, conference: FactoryGirl.attributes_for(:conference)
    end
  end

  test "should get edit" do
    get :edit, id: @conference.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update conference" do
    new_acronym = @conference.acronym + "1"
    put :update, conference: conference_params.merge(acronym: new_acronym), conference_acronym: @conference.acronym
    assert_redirected_to edit_conference_path(conference_acronym: new_acronym)
  end

  test "should get edit days" do
    get :edit_days, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should add conference_day" do
    assert_difference('Day.count') do
      @conference.days << FactoryGirl.create(:day)
      put :update, conference: conference_params, conference_acronym: @conference.acronym
    end
  end

  test "should create conference with feedback disabled" do
    assert_difference('Conference.count') do
      post :create, conference: FactoryGirl.attributes_for(:conference, feedback_enabled: false)
    end
  end

  test "should get edit notification" do
    get :edit_notifications, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should add notification" do
    params = {
      conference_acronym: @conference.acronym,
      conference: conference_params.merge(
        welcome_text: "welcome",
        notifications_attributes: {
          "0" => {
            reject_body: 'reject body text',
            reject_subject: 'rejected subject',
            accept_body: 'accept body text',
            accept_subject: 'accepted subject',
            locale: 'en'
          }
        }
      )
    }
    assert_difference('Notification.count') do
      put :update, params
    end
  end

  test "get default notification texts as json" do
    get :default_notifications, format: :json, code: "en", conference_acronym: @conference.acronym
    assert_response :success
  end
end

require 'test_helper'

class CallForPapersControllerTest < ActionController::TestCase

  setup do
    @call_for_papers = FactoryGirl.create(:call_for_papers)
    @conference = @call_for_papers.conference
    login_as(:admin)
  end

  def call_for_papers_params
    {
      start_date: Date.today.ago(1.days).strftime('%Y-%m-%d'),
      end_date: Date.today.since(6.days).strftime('%Y-%m-%d')
    }
  end

  test "should show cfp" do
    get :show, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should get new" do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should create cfp" do
    new_conference = FactoryGirl.create(:conference)
    params = {
      call_for_papers: call_for_papers_params,
      conference_acronym: new_conference.acronym
    }
    assert_difference('CallForPapers.count') do
      post :create, params
    end
  end

  test "should get edit" do
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update cfp" do
    params = {
      call_for_papers: call_for_papers_params.merge(welcome_text: "welcome"),
      conference_acronym: @conference.acronym
    }
    put :update, params
    assert_redirected_to call_for_papers_path(conference_acronym: @conference.acronym)
  end

  test "should get edit notification" do
    get :edit_notifications, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should add cfp notification" do
    params = {
      conference_acronym: @conference.acronym,
      call_for_papers: call_for_papers_params.merge(
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

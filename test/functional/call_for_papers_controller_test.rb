require 'test_helper'

class CallForPapersControllerTest < ActionController::TestCase

  setup do
    @call_for_papers = FactoryGirl.create(:call_for_papers)
    @conference = @call_for_papers.conference
    login_as(:admin)
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
    assert_difference('CallForPapers.count') do
      call_for_papers = FactoryGirl.build(:call_for_papers, conference: new_conference)
      post :create, call_for_papers: call_for_papers.attributes, conference_acronym: new_conference.acronym
    end
  end

  test "should get edit" do
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should update cfp" do
    put :update, call_for_papers: @call_for_papers.attributes.merge(welcome_text: "welcome"), conference_acronym: @conference.acronym
    assert_redirected_to call_for_papers_path(conference_acronym: @conference.acronym)
  end

  test "should get edit notification" do
    get :edit_notifications, conference_acronym: @conference.acronym
    assert_response :success
  end

  test "should add cfp notification" do
    assert_difference('Notification.count') do
      @call_for_papers.notifications << FactoryGirl.create(:notification)
      put :update, call_for_papers: @call_for_papers.attributes, conference_acronym: @conference.acronym
    end
  end

  test "get default notification texts as json" do
    get :default_notifications, format: :json, code: "en", conference_acronym: @conference.acronym
    assert_response :success
  end
end

require 'test_helper'

class Public::ScheduleControllerTest < ActionController::TestCase

  setup do
    @conference = FactoryGirl.create(:conference)
    10.times do
      FactoryGirl.create(:event, :conference => @conference, :state => "confirmed")
    end
  end

  test "displays schedule main page" do
    get :index, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "displays xml schedule" do
    get :index, :format => :xml, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "displays json schedule" do
    get :index, :format => :json, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "displays ical schedule" do
    get :index, :format => :ics, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "displays xcal schedule" do
    get :index, :format => :xcal, :conference_acronym => @conference.acronym
    assert_response :success
  end

end

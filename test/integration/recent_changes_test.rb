require 'test_helper'

class RecentChangesTest < ActionDispatch::IntegrationTest

  setup do
    @conference = create(:conference)
    @user = create(:user, :person => create(:person), :role => "admin")
    @tmp_user = create(:user, :person => create(:person), :role => "admin")
    post "/session", :user => {:email => @user.email, :password => "frab23"}
  end

  teardown do
    PaperTrail.enabled = false
  end

  test "home page still displays after event with person has been deleted" do
    event = create(:event, :conference => @conference)
    event_person = create(:event_person, :event => event)
    PaperTrail.enabled = true
    assert_difference "Event.count", -1 do
      delete "/#{@conference.acronym}/events/#{event.id}"
    end
    get "/", :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "home page still displays after initiator of change has been deleted" do
    post "/session", :user => {:email => @tmp_user.email, :password => "frab23"}
    PaperTrail.enabled = true
    event = create(:event, :conference => @conference)
    event_person = create(:event_person, :event => event)
    delete "/#{@conference.acronym}/people/#{@tmp_user.id}"
    post "/session", :user => {:email => @user.email, :password => "frab23"}
    get "/", :conference_acronym => @conference.acronym
    assert_response :success
  end
end

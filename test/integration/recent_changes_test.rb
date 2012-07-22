require 'test_helper'

class RecentChangesTest < ActionDispatch::IntegrationTest

  setup do
    @conference = create(:conference)
    user = create(:user, :person => create(:person), :role => "admin")
    post "/session", :user => {:email => user.email, :password => "frab23"}
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

end

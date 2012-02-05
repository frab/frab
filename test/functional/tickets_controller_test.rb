require 'test_helper'

class TicketsControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    @person = FactoryGirl.create(:person)
    FactoryGirl.create(:event_person, :event => @event, :person => @person, :event_role => "submitter")
    FactoryGirl.create(:event_person, :event => @event, :person => @person, :event_role => "speaker")

    @url = 'https://localhost/otrs/'
    #@ticket_server = FactoryGirl.create(:ticket_server) #, :conference => @conference, :url => @url, :queue => 'test')
    @conference.ticket_server = TicketServer.new(:conference => @conference, :url => @url, :queue => 'test', :user => 'guest', :password => 'guest')
    login_as(:admin)
  end

  test "create remote ticket" do
    assert true
    # TODO this will fail unless the ticket server works
    post :create, :event_id => @event.id, :conference_acronym => @conference.acronym
    assert_redirected_to event_path(assigns(:event))
  end
end

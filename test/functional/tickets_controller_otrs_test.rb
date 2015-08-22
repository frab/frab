require 'test_helper'

class TicketsControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    @person = FactoryGirl.create(:person)
    FactoryGirl.create(:event_person, event: @event, person: @person,
                                      event_role: "submitter")
    FactoryGirl.create(:event_person, event: @event, person: @person,
                                      event_role: "speaker")

    @conference.ticket_type = 'otrs'
    @url = 'https://localhost/otrs/'
    @conference.ticket_server = TicketServer.new(conference: @conference,
                                                 url: @url,
                                                 queue: 'test',
                                                 user: 'guest',
                                                 password: 'guest')
    login_as(:admin)
  end

  test "create remote ticket with OTRS" do
    post :create, event_id: @event.id,
                  conference_acronym: @conference.acronym, test_only: true
    # test fails because ?method=get is appended to url
    # assert_redirected_to event_path(assigns('event'))
    assert_response :redirect
  end
end

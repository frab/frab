require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  setup do
    @conference = create(:conference)
    @event = create(:event)
  end

  test 'should create a ticket' do
    ticket = Ticket.new(object_id: 1, object_type: 'Event',remote_ticket_id: '1')
    assert ticket.save
  end

  test 'should associate a ticket with an event' do
    ticket = Ticket.new(object_id: 1, object_type: 'Event', remote_ticket_id: '1')
    @event.ticket = ticket
    assert @event.save
  end
end

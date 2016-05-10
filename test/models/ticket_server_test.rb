require 'test_helper'

class TicketServerTest < ActiveSupport::TestCase
  setup do
    @conference = create(:conference)
    @url = 'https://localhost/otrs/'
  end

  test 'should create ticket server' do
    ticket_server = TicketServer.new(conference: @conference, url: @url, queue: 'test', user: 'guest', password: 'guest')
    assert ticket_server.save
  end

  test 'should associate a ticket server with a conference' do
    ticket_server = TicketServer.new(conference: @conference, url: @url, queue: 'test', user: 'guest', password: 'guest')
    @conference.ticket_server = ticket_server
    assert @conference.save
  end

  test 'should not save ticket server with empty url' do
    ticket_server = TicketServer.new(conference: @conference, queue: 'test', user: 'guest', password: 'guest')
    assert !ticket_server.save
  end

  test 'should not save ticket server with empty login user' do
    ticket_server = TicketServer.new(conference: @conference, url: @url, queue: 'test', password: 'guest')
    assert !ticket_server.save
  end

  test 'should not save ticket server with empty login password' do
    ticket_server = TicketServer.new(conference: @conference, url: @url, queue: 'test', user: 'guest')
    assert !ticket_server.save
  end

  test 'should not save ticket server with empty queue' do
    ticket_server = TicketServer.new(conference: @conference, url: @url, user: 'guest', password: 'guest')
    assert !ticket_server.save
  end

  test 'should not save ticket server url without trailing slash' do
    ticket_server = TicketServer.new(conference: @conference, url: 'https://localhost/otrs', queue: 'test', user: 'guest', password: 'guest')
    assert !ticket_server.save
  end
end

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should have_one :ticket
  should have_many :conflicts_as_conflicting
  should have_many :conflicts
  should have_many :event_attachments
  should have_many :event_feedbacks
  should have_many :event_people
  should have_many :event_ratings
  should have_many :links
  should have_many :people
  should have_many :videos
  should belong_to :conference
  should belong_to :track
  should belong_to :room
  should accept_nested_attributes_for :event_people
  should accept_nested_attributes_for :links
  should accept_nested_attributes_for :event_attachments
  should accept_nested_attributes_for :ticket
  should validate_presence_of :title
  should validate_presence_of :time_slots

  setup do
    ActionMailer::Base.deliveries = []
  end

  def setup_notification_event
    @notification = create(:notification)
    @event = create(:event, conference: @notification.conference)
    @speaker = create(:person)
    create(:event_person, event: @event, person: @speaker, event_role: 'speaker')
    @coordinator = create(:person)
  end

  test 'acceptance processing sends email if asked to' do
    setup_notification_event
    @event.process_acceptance(send_mail: true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  test 'acceptance processing sends german email if asked to' do
    setup_notification_event
    @speaker.languages << Language.new(code: 'de')
    @event.conference.languages << Language.new(code: 'de')
    notification = create(:notification, locale: 'de')
    @notification.conference.notifications << notification

    @event.process_acceptance(send_mail: true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  test 'acceptance processing does not send email by default' do
    setup_notification_event
    @event.process_acceptance(send_mail: false)
    assert ActionMailer::Base.deliveries.empty?
  end

  test 'acceptance processing sets coordinator' do
    setup_notification_event
    assert_difference 'EventPerson.count' do
      @event.process_acceptance(coordinator: @coordinator)
    end
  end

  test 'rejection processing sends email if asked to' do
    setup_notification_event
    @event.process_rejection(send_mail: true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  test 'rejection processing does not send email by default' do
    setup_notification_event
    @event.process_rejection(send_mail: false)
    assert ActionMailer::Base.deliveries.empty?
  end

  test 'rejection processing sets coordinator' do
    setup_notification_event
    assert_difference 'EventPerson.count' do
      @event.process_rejection(coordinator: @coordinator)
    end
  end

  test 'correctly detects overlapping of events' do
    event = create(:event)
    other_event = create(:event)
    other_event.start_time = event.start_time.ago(30.minutes)
    assert event.overlap?(other_event)
    other_event.start_time = event.start_time.ago(1.hour)
    refute event.overlap?(other_event)
  end

  test 'event conflicts are updated if availabilities change' do
    conference = create(:three_day_conference_with_events)
    first_event = conference.events.first
    assert_empty first_event.conflicts

    event_person = create(:event_person, event: first_event)
    refute_empty first_event.reload.conflicts

    availability = create(:availability, person: event_person.person, conference: conference,
                                         start_date: conference.days.first.start_date,
                                         end_date: conference.days.last.end_date)
    assert_empty first_event.reload.conflicts
    availability.update(start_date: conference.days.last.start_date)
    refute_empty first_event.reload.conflicts
  end

  test 'transitions to notifiable states only possible when bulk notifications enabled' do
    conference1 = create(:three_day_conference_with_events)
    conference2 = create(:three_day_conference_with_events)

    conference2.bulk_notification_enabled = true
    event1 = conference1.events.first
    event2 = conference2.events.first
    event1.state = :new
    event2.state = :new

    event1.accept({})
    event2.accept({})
    assert_equal event1.state, "unconfirmed"
    assert_equal event2.state, "accepting"

    event1 = conference1.events.second
    event2 = conference2.events.second
    event1.state = :new
    event2.state = :new

    event1.reject({})
    event2.reject({})
    assert_equal event1.state, "rejected"
    assert_equal event2.state, "rejecting"

  end
end

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
    [:three_day_conference_with_events,
     :sub_conference_with_events].each do |conference_type|
      conference = create(conference_type)
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
  end

  test 'possible start times for event' do
    [:three_day_conference_with_events,
     :sub_conference_with_events].each do |conference_type|
      conference = create(conference_type)
      event = conference.events.first
      day = conference.days.first

      event_person_a = create(:event_person, event: event)
      person_a = event_person_a.person

      availability = create(:availability, person: person_a, conference: conference,
                                           start_date: day.start_date,
                                           end_date: day.start_date + 2.hours)

      event_person_b = create(:event_person, event: event)
      person_b = event_person_b.person
      availability = create(:availability, person: person_b, conference: conference,
                                           start_date: day.start_date + 1.hours,
                                           end_date: day.start_date + 3.hours)

      possible = event.possible_start_times
      possible_days = possible.keys
      assert possible_days.count == 1

      possible_times = possible[possible_days.first]

      # 5 possible time slots, plus 1 extra for the one the event is currently scheduled on
      assert possible_times.count == 6
    end
  end
end

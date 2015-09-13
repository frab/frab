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
    @notification = create(:notification)
    @event = create(:event, conference: @notification.conference)
    @speaker = create(:person)
    create(:event_person, event: @event, person: @speaker, event_role: "speaker")
    @coordinator = create(:person)
  end

  test "acceptance processing sends email if asked to" do
    @event.process_acceptance(send_mail: true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  test "acceptance processing sends german email if asked to" do
    @speaker.languages << Language.new(code: 'de')
    @event.conference.languages << Language.new(code: 'de')
    notification = create(:notification, locale: 'de')
    @notification.conference.notifications << notification

    @event.process_acceptance(send_mail: true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  test "acceptance processing does not send email by default" do
    @event.process_acceptance(send_mail: false)
    assert ActionMailer::Base.deliveries.empty?
  end

  test "acceptance processing sets coordinator" do
    assert_difference "EventPerson.count" do
      @event.process_acceptance(coordinator: @coordinator)
    end
  end

  test "rejection processing sends email if asked to" do
    @event.process_rejection(send_mail: true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  test "rejection processing does not send email by default" do
    @event.process_rejection(send_mail: false)
    assert ActionMailer::Base.deliveries.empty?
  end

  test "rejection processing sets coordinator" do
    assert_difference "EventPerson.count" do
      @event.process_rejection(coordinator: @coordinator)
    end
  end

  test "correctly detects overlapping of events" do
    other_event = create(:event)
    other_event.start_time = @event.start_time.ago(30.minutes)
    assert @event.overlap?(other_event)
    other_event.start_time = @event.start_time.ago(1.hour)
    assert !@event.overlap?(other_event)
  end
end

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries = []
    @notification = FactoryGirl.create(:notification)
    @event = FactoryGirl.create(:event, conference: @notification.conference)
    @speaker = FactoryGirl.create(:person)
    FactoryGirl.create(:event_person, event: @event, person: @speaker, event_role: "speaker")
    @coordinator = FactoryGirl.create(:person)
  end

  test "acceptance processing sends email if asked to" do
    @event.process_acceptance(send_mail: true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  test "acceptance processing sends german email if asked to" do
    @speaker.languages << Language.new(code: 'de')
    @event.conference.languages << Language.new(code: 'de')
    notification = FactoryGirl.create(:notification, locale: 'de')
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
    other_event = FactoryGirl.create(:event)
    other_event.start_time = @event.start_time.ago(30.minutes)
    assert @event.overlap?(other_event)
    other_event.start_time = @event.start_time.ago(1.hour)
    assert !@event.overlap?(other_event)
  end
end

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries = []
    I18n.locale = :en
    Mobility.locale = nil
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
    %i(three_day_conference_with_events sub_conference_with_events).each do |conference_type|
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

  test 'event conflicts are created if one person is speaker is already speaking' do
    conference = create(:three_day_conference_with_events)
    first_event = conference.events.first
    new_room = create(:room, conference: conference)
    new_event = create(:event, conference: conference, room: new_room, state: 'confirmed', start_time: first_event.start_time)
    assert_empty first_event.conflicts
    assert conference.events.include?(new_event)

    event_person1 = create(:confirmed_speaker, conference: conference, event: first_event)
    create(:confirmed_speaker, conference: conference, event: new_event, person: event_person1.person)

    refute_empty first_event.reload.conflicts
    refute_empty new_event.reload.conflicts
    refute_empty Conflict.all
  end

  test 'possible start times for event' do
    %i(three_day_conference_with_events sub_conference_with_events).each do |conference_type|
      conference = create(conference_type)
      event = conference.events.first
      day = conference.days.first

      event_person_a = create(:event_person, event: event)
      person_a = event_person_a.person
      create(:availability, person: person_a, conference: conference,
             start_date: day.start_date,
             end_date: day.start_date + 2.hours)

      event_person_b = create(:event_person, event: event)
      person_b = event_person_b.person
      create(:availability, person: person_b, conference: conference,
             start_date: day.start_date + 1.hour,
             end_date: day.start_date + 3.hours)

      possible = PossibleStartTimes.new(event).all
      possible_days = possible.keys
      assert possible_days.count == 1

      possible_times = possible[possible_days.first]

      # 5 possible time slots, plus 1 extra for the one the event is currently scheduled on
      assert possible_times.count == 6
    end
  end

  test 'transitions to notifiable states only possible when bulk notifications enabled' do
    conference1 = create(:three_day_conference_with_events)
    conference2 = create(:three_day_conference_with_events)

    conference2.bulk_notification_enabled = true
    event1 = conference1.events.first
    event2 = conference2.events.first
    event1.state = 'new'
    event2.state = 'new'

    event1.accept({})
    event2.accept({})
    assert_equal event1.state, 'unconfirmed'
    assert_equal event2.state, 'accepting'

    event1 = conference1.events.second
    event2 = conference2.events.second
    event1.state = 'new'
    event2.state = 'new'

    event1.reject({})
    event2.reject({})
    assert_equal event1.state, 'rejected'
    assert_equal event2.state, 'rejecting'
  end

  test 'notifiable is only true if all checks match' do
    conference = create(:three_day_conference_with_events)
    event = conference.events.first

    conference.bulk_notification_enabled = true
    conference.ticket_type = 'rt'
    event.state = 'accepting'
    event.ticket = Ticket.new(object_id: 1, object_type: 'Event', remote_ticket_id: '1')

    assert_not event.notifiable
    create(:event_person, event: event)
    assert event.notifiable
    conference.bulk_notification_enabled = false
    assert_not event.notifiable
    conference.bulk_notification_enabled = true
    event.state = 'accepted'
    assert_not event.notifiable
    event.state = 'accepting'
    event.ticket = nil
    assert_not event.notifiable
    conference.ticket_type = 'integrated'
    assert event.notifiable
  end

  test 'create with nested attributes is valid' do
    event = build(:event)

    link_plan = { 'title' => 'title value', 'url' => 'http://test.com' }
    event.links_attributes = { 'random-string' => link_plan }

    upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'textfile.txt'), 'text/plain')
    event_attachment_plan = { 'title' => 'title value', 'attachment' => upload }
    event.event_attachments_attributes = { 'random-string' => event_attachment_plan }

    event.valid? # trigger validations
    assert_empty event.errors.full_messages
  end

  test 'localization setup' do
    conference = create(:multilingual_conference)
    event = conference.events.first

    # this test assumes I18n.default_locale is :en and won't work otherwise
    assert_equal :en, I18n.default_locale
    assert_equal I18n.default_locale, I18n.locale
    assert_equal I18n.default_locale, Mobility.locale

    title_org = event.title

    # data is still stored on the model by default
    assert_equal title_org, event['title']

    # ar has no fallback, no value for unknown locales
    assert_nil event.title_ar
    # other accessors behave the same
    assert_nil event.title(locale: :ar)

    Mobility.with_locale(:ar) do
      assert_nil event.title
    end

    # de has fallback, no value for unset conference locales via locale_accessor
    assert_nil event.title_de

    # using locale with I18n.fallback, fallbacks work
    Mobility.with_locale(:de) do
      assert_equal title_org, event.title
    end

    # en being the default just works
    assert_equal title_org, event.title_en

    # setting another language
    Mobility.with_locale(:de) do
      event.title = 'deu'
      event.save!
    end
    event.reload

    # it is accessible
    assert_equal 'deu', event.title_de
    Mobility.with_locale(:de) do
      assert_equal 'deu', event.title
    end

    # others still work
    assert_equal title_org, event.title_en
    assert_nil event.title_ar

    # and the number of translations increased
    assert_equal 1, Event::Translation.count

    # without locale, reader uses the fallback language
    Mobility.with_locale(nil) do
      assert_equal title_org, event.title
    end

    # changing I18n.fallback locale works, too
    I18n.with_locale(:zh) do
      event.title = 'zh'
      event.save
    end
    assert_equal 'zh', event.reload.title_zh
  end

  test 'cannot add event with another language to conference' do
    conference = create(:multilingual_conference)
    event = build(:event, language: 'fr', conference: conference)
    event.valid?
    assert_includes event.errors.full_messages, 'Language locale must match a conference locale'
  end

  # Event locking tests
  test 'event is not locked by default' do
    event = create(:event)
    assert_not event.locked?
  end

  test 'event can be locked' do
    event = create(:event)
    event.update!(locked: true)
    assert event.locked?
  end

  test 'event can be unlocked' do
    event = create(:event, locked: true)
    event.update!(locked: false)
    assert_not event.locked?
  end

  test 'locked? method returns correct boolean value' do
    event = create(:event)
    assert_not event.locked?
    
    event.locked = true
    assert event.locked?
    
    event.locked = false
    assert_not event.locked?
  end
end

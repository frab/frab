require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase
  test 'current returns the newest conference' do
    time = Time.now
    create(:conference, created_at: time.ago(3.hour))
    create(:conference, created_at: time.ago(2.hour))
    conference = create(:conference, created_at: time.ago(1.hour))
    assert_equal conference.id, Conference.current.id
  end

  test 'returns correct language codes' do
    conference = create(:conference)
    conference.languages << create(:english_language, attachable: conference)
    conference.languages << create(:german_language, attachable: conference)
    assert_equal 2, conference.language_codes.size
    assert conference.language_codes.include? 'en'
    assert conference.language_codes.include? 'de'
  end

  test 'returns the correct days' do
    conference = create(:three_day_conference)
    assert_equal 3, conference.days.size
    assert_equal Date.today.since(3.days).since(10.hours), conference.days.last.start_date
  end

  test '#has_submission' do
    %i(three_day_conference_with_events sub_conference_with_events).each do |conference_type|
      conference = create(conference_type)
      event = conference.events.first
      person = create(:person)
      create(:confirmed_event_person, event: event, person: person)
      assert Conference.has_submission(person)

      conference = create(conference_type)
      event = conference.events.first
      create(:confirmed_event_person, event: event, person: person)
      create(:confirmed_event_person, event: event)
      assert_equal 2, Conference.has_submission(person).count

      conference = create(conference_type)
      event = conference.events.first
      create(:event_person, event: event, person: person, event_role: 'coordinator')
      assert_equal 2, Conference.has_submission(person).count
    end
  end

  test '#past' do
    assert_empty Conference.past
    past = create(:past_days_conference, title: 'past conference')
    create(:past_call_for_participation, conference: past)
    past = create(:past_days_conference, title: 'past conference')
    create(:past_call_for_participation, conference: past)
    assert_equal 2, Conference.past.count
  end

  test '#future' do
    assert_empty Conference.future
    future = create(:three_day_conference, title: 'future conference')
    create(:future_call_for_participation, conference: future)
    future = create(:three_day_conference, title: 'future conference')
    create(:future_call_for_participation, conference: future)
    assert_equal 4, Conference.future.count
  end

  test 'inherits from parent conference' do
    parent_conference = create(:three_day_conference_with_events)
    sub_conference = create(:conference)
    sub_conference.update_attributes(parent: parent_conference)

    parent_conference.update_attributes(timeslot_duration: 10)
    assert_equal sub_conference.timeslot_duration, parent_conference.timeslot_duration

    parent_conference.update_attributes(timezone: 'Honululu')
    assert_equal sub_conference.timezone, parent_conference.timezone

    sub_conference.days.destroy_all
    assert_equal sub_conference.days.count, parent_conference.days.count
  end
end

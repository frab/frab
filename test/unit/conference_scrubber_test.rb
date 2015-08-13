require 'test_helper'

class ConferenceScrubberTest < ActiveSupport::TestCase

  TEXT = "text message"
  DUMMY_MAIL = "root@localhost.localdomain"

  setup do
    @conference = FactoryGirl.create(:conference)
    add_day(@conference, 2.years)
    @event_person = add_event_with_speaker(@conference)
    ENV['QUIET'] = '1'
  end

  def add_day(conference, time)
    conference.days << FactoryGirl.create(:day,
      start_date: Date.today.ago(time).since(11.hours),
      end_date: Date.today.ago(time).since(23.hours))
  end

  def add_event_with_speaker(conference)
    event = FactoryGirl.create(:event, conference: conference, state: "confirmed")
    FactoryGirl.create(:event_person, event: event)
  end

  test "should find last years conferences" do
    c_new = FactoryGirl.create(:conference)
    add_day(c_new, 1.days)

    @scrubber = ConferenceScrubber.new(@conference)
    last_years = @scrubber.send(:get_last_years_conferences)
    assert_equal 1, last_years.count
  end

  test "should recognize person active in conference" do
    c_new = FactoryGirl.create(:conference)
    add_day(c_new, 1.days)
    event_person = add_event_with_speaker(c_new)

    @scrubber = ConferenceScrubber.new(@conference)
    is_active = @scrubber.send(:still_active, event_person.person)
    assert is_active
  end

  test "should recognize person not active in conference" do
    @scrubber = ConferenceScrubber.new(@conference)
    is_active = @scrubber.send(:still_active, @event_person.person)
    assert !is_active
  end

  test "should clear persons contact data" do
    @scrubber = ConferenceScrubber.new(@conference)
    person =  FactoryGirl.create(:person)
    person.email_public = false
    person.phone_numbers << PhoneNumber.new
    person.im_accounts << ImAccount.new
    person.note = TEXT
    person.save!

    @scrubber.send(:scrub_person, person)
    person.reload
    assert_equal person.email, DUMMY_MAIL
    assert person.phone_numbers.blank?
    assert person.im_accounts.blank?
    assert_nil person.note
  end

  test "should recognize person not active in any conference" do
    person =  FactoryGirl.create(:person)
    assert !person.active_in_any_conference?
  end

  test "should recognize person active in some conference" do
    assert @event_person.person.active_in_any_conference?
  end

  test "should clear persons biographical data" do
    person =  FactoryGirl.create(:person, abstract: TEXT, description: TEXT)
    @scrubber = ConferenceScrubber.new(@conference)
    @scrubber.send(:scrub_person, person)
    person.reload
    assert_nil person.abstract
    assert_nil person.description
  end

  test "should scrub all event ratings of a conference" do
    event = @event_person.event
    FactoryGirl.create(:event_rating, event: event)
    FactoryGirl.create(:event_rating, event: event)
    FactoryGirl.create(:event_rating, event: event)

    @scrubber = ConferenceScrubber.new(@conference)
    @scrubber.send(:scrub_event_ratings)

    # reload
    event.reload
    assert event.event_ratings.blank?
  end

end

require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase
  should have_many :availabilities
  should have_many :conference_users
  should have_many :days
  should have_many :events
  should have_many :languages
  should have_many :notifications
  should have_many :rooms
  should have_many :tracks
  should have_many :conference_exports
  should have_one :call_for_participation
  should have_one :ticket_server
  should validate_presence_of :title
  should validate_presence_of :acronym
  should validate_presence_of :default_timeslots
  should validate_presence_of :max_timeslots
  should validate_presence_of :timeslot_duration
  should validate_presence_of :timezone

  test "current returns the newest conference" do
    conferences = create_list(:conference, 3)
    assert_equal conferences.last.id, Conference.current.id
  end

  test "returns correct language codes" do
    conference = create(:conference)
    conference.languages << create(:english_language)
    conference.languages << create(:german_language)
    assert_equal 2, conference.language_codes.size
    assert conference.language_codes.include? "en"
    assert conference.language_codes.include? "de"
  end

  test "returns the correct days" do
    conference = create(:three_day_conference)
    assert_equal 3, conference.days.size
    assert_equal Date.today.since(3.days).since(10.hours), conference.days.last.start_date
  end
end

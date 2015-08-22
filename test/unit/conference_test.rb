require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase
  test "current returns the newest conference" do
    conferences = FactoryGirl.create_list(:conference, 3)
    assert_equal conferences.last.id, Conference.current.id
  end

  test "returns correct language codes" do
    conference = FactoryGirl.create(:conference)
    conference.languages << FactoryGirl.create(:english_language)
    conference.languages << FactoryGirl.create(:german_language)
    assert_equal 2, conference.language_codes.size
    assert conference.language_codes.include? "en"
    assert conference.language_codes.include? "de"
  end

  test "returns the correct days" do
    conference = FactoryGirl.create(:three_day_conference)
    assert_equal 3, conference.days.size
    assert_equal Date.today.since(3.days).since(10.hours), conference.days.last.start_date
  end
end

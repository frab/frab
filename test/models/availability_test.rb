require 'test_helper'

class AvailabilityTest < ActiveSupport::TestCase
  setup do
    @conference = FactoryGirl.create(:three_day_conference)
  end

  test 'build_for creates availabilites for each conference day' do
    availabilities = Availability.build_for(@conference)
    assert_equal @conference.days.size, availabilities.size
    assert_equal @conference.days.first.start_date, availabilities.first.start_date
    assert_equal @conference.days.last.end_date, availabilities.last.end_date
  end

  test 'correctly determines if given time is within current range' do
    availability = FactoryGirl.build(:availability, conference: @conference)
    availability.start_date = availability.day.start_date.since(1.hours)
    availability.end_date = availability.day.end_date.ago(4.hours)
    time = availability.start_date
    assert availability.within_range?(time)
    time = time.since(3.hours)
    assert availability.within_range?(time)
    time = time.since(4.hours)
    assert availability.within_range?(time)
    time = time.since(10.hours)
    assert !availability.within_range?(time)
  end

  test 'correctly handles full day' do
    availability = FactoryGirl.build(:availability, conference: @conference)
    availability.start_date = Time.parse('00:00:00').ago(5.hours)
    availability.end_date = Time.parse('00:00:00').since(5.hours)
    time = Time.parse('00:00:00')
    assert availability.within_range?(time)
    time = Time.parse('03:00:00')
    assert availability.within_range?(time)
    time = Time.parse('04:00:00')
    assert availability.within_range?(time)
    time = Time.parse('00:00:00').ago(4.hours)
    assert availability.within_range?(time)
    time = Time.parse('00:00:00').ago(7.hours)
    assert !availability.within_range?(time)
  end
end

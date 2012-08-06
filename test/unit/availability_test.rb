require 'test_helper'

class AvailabilityTest < ActiveSupport::TestCase

  setup do
    @conference = FactoryGirl.create(:conference)
  end

  test "build_for creates availabilites for each conference day" do
    availabilities = Availability.build_for(@conference)
    assert_equal @conference.days.size, availabilities.size
    assert_equal @conference.day_start, availabilities.first.start_time.hour
    assert_equal @conference.day_end, availabilities.last.end_time.hour
  end

  test "build_for works with all day conferences" do
    @conference.day_start = 0
    @conference.day_end = 24
    availabilities = Availability.build_for(@conference)
    assert_equal @conference.days.size, availabilities.size
    assert_equal @conference.day_start, availabilities.first.start_time.hour
    assert_equal @conference.day_end, availabilities.last.end_time.hour
  end

  test "time_range can be set and read successfully" do
    availability = FactoryGirl.build(:availability, :conference => @conference)
    availability.time_range = "7-23"
    assert_equal "7-23", availability.time_range
    availability.time_range = "0-12"
    assert_equal "0-12", availability.time_range
    availability.time_range = "12-24"
    assert_equal "12-24", availability.time_range
  end

  test "correctly determines if given time is within current range" do
    availability = FactoryGirl.build(:availability, :conference => @conference)
    availability.time_range = "10-12"
    time = Time.parse("09:00:00")
    assert !availability.within_range?(time)
    time = time.since(1.hours)
    assert availability.within_range?(time)
    time = time.since(1.hours)
    assert availability.within_range?(time)
    time = time.since(1.hours)
    assert availability.within_range?(time)
    time = time.since(1.hours)
    assert !availability.within_range?(time)
  end

  test "correctly handles full day" do
    availability = FactoryGirl.build(:availability, :conference => @conference)
    availability.time_range = "0-24"
    time = Time.parse("00:00:00")
    assert availability.within_range?(time)
    time = Time.parse("15:00:00")
    assert availability.within_range?(time)
    time = Time.parse("23:00:00")
    assert availability.within_range?(time)
    # FIXME 
    time = Time.parse("23:59:59")
    assert availability.within_range?(time)
    time = Time.parse("24:00:00")
    assert !availability.within_range?(time)
  end

end

require 'test_helper'

class AvailabilityTest < ActiveSupport::TestCase

  setup do
    @conference = FactoryGirl.create(:conference)
  end

  test "build_for creates availabilites for each conference day" do
    availabilities = Availability.build_for(@conference)
    assert_equal @conference.days.size, availabilities.size
  end

  test "time_range can be set and read successfully" do
    availability = FactoryGirl.build(:availability, :conference => @conference)
    availability.time_range = "7-23"
    assert_equal "7-23", availability.time_range
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

end

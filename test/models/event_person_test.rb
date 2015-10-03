require 'test_helper'

class EventPersonTest < ActiveSupport::TestCase
  test "confirmation advances both person's and event's state if possible" do
    event = FactoryGirl.create(:event, state: "unconfirmed")
    person = FactoryGirl.create(:person)
    event_person = FactoryGirl.create(:event_person, event: event, person: person, role_state: "offer")
    event_person.confirm!
    assert_equal "confirmed", event_person.role_state
    assert_equal "confirmed", event.state
  end

  test "confirmation token gets generated" do
    event_person = FactoryGirl.create(:event_person)
    assert_nil event_person.confirmation_token
    event_person.generate_token!
    assert_not_nil event_person.confirmation_token
  end

  test "checks for availability correctly" do
    today = Date.today
    conference = FactoryGirl.create(:three_day_conference)
    event = FactoryGirl.create(:event, conference: conference)
    person = FactoryGirl.create(:person)
    availability = FactoryGirl.create(:availability, conference: conference, person: person, start_date: Time.parse("10:00"), end_date: Time.parse("14:00"))
    event_person = FactoryGirl.create(:event_person, event: event, person: person)
    assert event_person.available_between?(today.to_time.change(hour: 11), today.to_time.change(hour: 13))
    assert event_person.available_between?(today.to_time.change(hour: 10), today.to_time.change(hour: 14))
    assert !event_person.available_between?(today.to_time.change(hour: 9), today.to_time.change(hour: 11))
    assert !event_person.available_between?(today.to_time.change(hour: 0), today.to_time.change(hour: 11))
    assert !event_person.available_between?(today.to_time.change(hour: 13), today.to_time.change(hour: 24))
  end
end

require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "full public name prioritizes public name" do
    person = FactoryGirl.create(:person, public_name: "public name test")
    assert_not_nil person.last_name
    assert_equal "public name test", person.full_public_name
  end

  test "feedback average gets calculated correctly" do
    conference = FactoryGirl.create(:conference)
    event1 = FactoryGirl.create(:event, conference: conference)
    event2 = FactoryGirl.create(:event, conference: conference)
    event3 = FactoryGirl.create(:event, conference: conference)
    person = FactoryGirl.create(:person)
    FactoryGirl.create(:event_person, event: event1, person: person, event_role: :speaker)
    FactoryGirl.create(:event_person, event: event2, person: person, event_role: :speaker)
    FactoryGirl.create(:event_person, event: event3, person: person, event_role: :speaker)

    FactoryGirl.create(:event_feedback, event: event1, rating: 3.0)
    FactoryGirl.create(:event_feedback, event: event2, rating: 4.0)
    assert_equal 3.5, person.average_feedback_as_speaker

    # FIXME doesn't register another feedback for event2, thus
    # using a new one
    FactoryGirl.create(:event_feedback, event: event3, rating: 5.0)
    assert_equal 4.0, person.average_feedback_as_speaker
  end
end

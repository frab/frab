require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "#full_name" do
    person = build(:person)
    assert_equal "Fred Besen", person.full_name
    person = build(:person, first_name: 'Fred')
    assert_equal "Fred Besen", person.full_name
    person = build(:person, first_name: 'Bred', last_name: 'Fesen')
    assert_equal "Bred Fesen", person.full_name
  end

  test "feedback average gets calculated correctly" do
    conference = create(:conference)
    event1 = create(:event, conference: conference)
    event2 = create(:event, conference: conference)
    event3 = create(:event, conference: conference)
    person = create(:person)
    create(:event_person, event: event1, person: person, event_role: :speaker)
    create(:event_person, event: event2, person: person, event_role: :speaker)
    create(:event_person, event: event3, person: person, event_role: :speaker)

    create(:event_feedback, event: event1, rating: 3.0)
    create(:event_feedback, event: event2, rating: 4.0)
    assert_equal 3.5, person.average_feedback_as_speaker

    # FIXME doesn't register another feedback for event2, thus
    # using a new one
    create(:event_feedback, event: event3, rating: 5.0)
    assert_equal 4.0, person.average_feedback_as_speaker
  end
end

require 'test_helper'

class ConflictTest < ActiveSupport::TestCase
  test "creates person conflict" do
    event_person = FactoryGirl.create :event_person
    event = event_person.event
    conflict = Conflict.create(event: event, person: event_person.person, conflict_type: "person_has_no_availability", severity: "warning")
    assert conflict.valid?
    assert conflict.id
  end

  test "creates event conflict" do
    event = FactoryGirl.create :event
    conflicting_event = FactoryGirl.create :event
    conflict = Conflict.create(event: event, conflicting_event: conflicting_event, conflict_type: "events_overlap", severity: "fatal")
    assert conflict.valid?
    assert conflict.id
  end
end

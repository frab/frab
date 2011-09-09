require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  test "full public name prioritizes public name" do
    person = FactoryGirl.create(:person, :public_name => "public name test")
    assert_not_nil person.last_name
    assert_equal "public name test", person.full_public_name
  end

  test "feedback average gets calculated correctly" do
    conference = FactoryGirl.create(:conference)
    event1 = FactoryGirl.create(:event, :conference => conference)
    event2 = FactoryGirl.create(:event, :conference => conference)
    person = FactoryGirl.create(:person)
    FactoryGirl.create(:event_person, :event => event1, :person => person)
    FactoryGirl.create(:event_person, :event => event2, :person => person)
    FactoryGirl.create(:event_feedback, :event => event1, :rating => 4.0)
    FactoryGirl.create(:event_feedback, :event => event2, :rating => 4.0)
    assert_equal 4.0, person.average_feedback_as_speaker
    FactoryGirl.create(:event_feedback, :event => event2, :rating => 2.0)
    assert_equal 3.5, person.average_feedback_as_speaker
  end

end

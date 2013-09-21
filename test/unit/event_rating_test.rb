require 'test_helper'

class EventRatingTest < ActiveSupport::TestCase

  test "creating ratings correctly updates average" do
    event = FactoryGirl.create(:event)
    FactoryGirl.create(:event_rating, event: event, rating: 4.0)
    event.reload
    assert_equal 4.0, event.average_rating
    FactoryGirl.create(:event_rating, event: event, rating: 4.0)
    event.reload
    assert_equal 4.0, event.average_rating
    FactoryGirl.create(:event_rating, event: event, rating: 1.0)
    event.reload
    assert_equal 3.0, event.average_rating
  end

  test "person can only submit one rating per event" do
    event = FactoryGirl.create(:event)
    person = FactoryGirl.create(:person)

    er = EventRating.new event: event, person: person, rating: 4.0
    assert er.save

    er = EventRating.new event: event, person: person, rating: 4.0
    assert !er.save
  end

end

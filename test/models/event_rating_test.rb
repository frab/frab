require 'test_helper'

class EventRatingTest < ActiveSupport::TestCase
  test 'creating ratings correctly updates average' do
    event = create(:event)
    id = event.id

    create(:event_rating, event: event, rating: 8.0)
    update_average(id)
    assert_equal 8.0, Event.find(id).average_rating

    create(:event_rating, event: event, rating: 4.0)
    update_average(id)
    assert_equal 6.0, Event.find(id).average_rating

    create(:event_rating, event: event, rating: 3.0)
    update_average(id)
    assert_equal 5.0, Event.find(id).average_rating
  end

  test 'person can only submit one rating per event' do
    event = create(:event)
    person = create(:person)

    er = EventRating.new event: event, person: person, rating: 4.0
    assert er.save

    er = EventRating.new event: event, person: person, rating: 5.0
    assert er.save
    assert_equal 5.0, EventRating.find(er.id).rating
  end

  private

  def update_average(id)
    event = Event.find(id)
    event.recalculate_average_rating!
    event.save!
  end
end

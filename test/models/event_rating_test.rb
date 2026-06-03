require 'test_helper'

class EventRatingTest < ActiveSupport::TestCase
  test 'creating ratings correctly updates average' do
    event = create(:event)
    id = event.id

    create(:event_rating, event: event, rating: 4.0)
    update_average(id)
    assert_equal 4.0, Event.find(id).average_rating

    create(:event_rating, event: event, rating: 2.0)
    update_average(id)
    assert_equal 3.0, Event.find(id).average_rating

    create(:event_rating, event: event, rating: 3.0)
    update_average(id)
    assert_equal 3.0, Event.find(id).average_rating
  end

  test 'rating must be between 0 and 5' do
    event = create(:event)
    person = create(:person)

    assert EventRating.new(event: event, person: person, rating: 0).valid?
    assert EventRating.new(event: event, person: person, rating: 5).valid?
    assert EventRating.new(event: event, person: person, rating: nil).valid?
    assert_not EventRating.new(event: event, person: person, rating: -1).valid?
    assert_not EventRating.new(event: event, person: person, rating: 5.1).valid?
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

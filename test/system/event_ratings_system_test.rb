require 'application_system_test_case'

# Generated test cases
class EventRatingsSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:conference, acronym: 'testconf')
    @metric = create(:review_metric, conference: @conference, name: 'Quality')
    @crew = create(:conference_reviewer, conference: @conference)
    @event = create(:event, conference: @conference, title: 'Test Event')
  end

  test 'crew can access event rating page' do
    sign_in_user(@crew.user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"

    assert_content page, 'Test Event'
  end

  test 'event rating page shows event details section' do
    sign_in_user(@crew.user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"

    assert_content page, 'Event details'
  end

  test 'event rating page shows my rating section' do
    sign_in_user(@crew.user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"

    assert_content page, 'My rating'
  end

  test 'event rating page shows all ratings section' do
    sign_in_user(@crew.user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"

    assert_content page, 'All ratings'
  end

  test 'event rating page shows no ratings message when no ratings exist' do
    sign_in_user(@crew.user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"

    assert_content page, 'No one has entered a rating for this event yet'
  end

  test 'event rating form contains rating and comment fields' do
    sign_in_user(@crew.user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"

    assert_field 'Comment'
    assert_content page, 'Rating' # Rating field exists
  end

  test 'event rating form shows review metrics when available' do
    sign_in_user(@crew.user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"

    assert_content page, 'Quality'
    assert_content page, 'Review Metrics'
  end
end

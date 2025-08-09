require 'application_system_test_case'

class EditingEventReviewTest < ApplicationSystemTestCase
  REVIEW_METRIC_NAME = 'optimistic :-)'

  setup do
    @conference = create(:three_day_conference_with_review_metrics_and_events)
    @event = @conference.events.last
    @review_metric = @conference.review_metrics.first

    # When test start, three people already reviewed it
    [2, 4, 5].each do |score|
      reviewer = create(:conference_coordinator, conference: @conference)
      event_rating = create(:event_rating, event: @event, person: reviewer.person)
      create(:review_score, event_rating: event_rating, review_metric: @review_metric, score: score)
    end
    @event.save

    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user
  end

  test 'can edit review metrics and delete, calculate average' do
    # Test that when @user updates the review score, the average is updated correctly
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
    # Click 4-star rating for all review metrics
    all("label[for*='review_score'][for$='star4']").each(&:click)
    click_on 'Create rating'
    assert_content page, 'saved successfully'

    visit "/#{@conference.acronym}/events/ratings"
    assert_content page, @review_metric.name
    assert_content page, '3.75' # average([2,4,4,5])

    # Test that filtering by review metric works
    click_on '3.75'
    assert_content page, '≥ 3.75'
    assert_content page, @event.title

    # Test that when @user deletes the review, the average is updated correctly
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
    accept_alert do
      find('button i.bi-trash').ancestor('button').click
    end
    assert_content page, 'deleted successfully'

    visit "/#{@conference.acronym}/events/ratings"
    assert_content page, @review_metric.name
    assert_content page, '3.67' # average([2,4,5])
  end
end

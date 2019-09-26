require 'test_helper'

class EditingEventReviewTest < FeatureTest
  REVIEW_METRIC_NAME = 'innovative חדשני'
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last

    review_metric = ReviewMetric.create(name: REVIEW_METRIC_NAME, conference: @conference)
    @conference.review_metrics << review_metric

    # When test start, three people already reviewed it
    [2, 4, 5].each do |score|
      reviewer=create(:conference_coordinator, conference: @conference)
      @event.event_ratings_attributes = [{ person: reviewer.person, review_scores_attributes: [{review_metric: review_metric, score: score}] }]
    end
    @event.save

    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user
  end

  it 'can edit review metrics and delete, calculate average', js:true do
     # Test that when @user updates the review score, the average is updated correctly
     sign_in_user(@user)
     visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
     find('span', exact_text: '4').find('input').click()
     click_on 'Create Event rating'
     assert_content page, 'saved successfully' 
     
     visit "/#{@conference.acronym}/events/ratings"
     assert_content page, REVIEW_METRIC_NAME 
     assert_content page, '3.75' # average([2,4,4,5])

     # Test that when @user deletes the review, the average is updated correctly
     visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
     click_on 'Delete Event rating'
     assert_content page, 'deleted successfully' 
     
     visit "/#{@conference.acronym}/events/ratings"
     assert_content page, REVIEW_METRIC_NAME 
     assert_content page, '3.67' # average([2,4,5])

     # Test that sorting by review metric doesn't assert
     click_on REVIEW_METRIC_NAME
     assert_content page, REVIEW_METRIC_NAME
     
     
  end
end

require 'test_helper'

class EventClassifierTest < ActiveSupport::TestCase
  test "can create event classifiers" do
    conference = create(:three_day_conference_with_events)
    classifier = create(:classifier, conference: conference)
    event_classifier = create(:event_classifier, classifier: classifier, event: conference.events.first)
    assert_equal(conference.events.first.event_classifiers.count, 1)
    assert_raise do
      # must not allow to EventClassifiers for same Classifier
      create(:event_classifier, classifier: classifier, event: conference.events.first)
    end
    assert_equal(conference.events.first.event_classifiers.count, 1)
    classifier.destroy
    assert_equal(conference.events.first.event_classifiers.count, 0)
  end
end

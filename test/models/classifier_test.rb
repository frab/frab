require 'test_helper'

class ClassifierTest < ActiveSupport::TestCase
  should belong_to: :conference
  should have_many: :event_classifiers

  test "can create a classifier" do
    conference = create(:conference)
    classifier = create(:classifier, conference: conference)
  end
end

require 'test_helper'

class ClassifierTest < ActiveSupport::TestCase
  test 'can create a classifier' do
    conference = create(:conference)
    classifier = create(:classifier, conference: conference)
    assert_equal(conference.classifiers.count,1)
    create(:classifier, conference: conference)
    assert_equal(conference.classifiers.count,2)
    classifier.destroy
    assert_equal(conference.classifiers.count,1)
  end
end

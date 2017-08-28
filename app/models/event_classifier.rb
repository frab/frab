class EventClassifier < ActiveRecord::Base
  belongs_to :classifier
  belongs_to :event, inverse_of: :event_classifiers

  # do not allow the same categories on an event TODO: make error message prettier
  validates_uniqueness_of :classifier_id, scope: %i[event_id]

  validates :value, presence: true
  validates :value, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100, only_integer: true }
end

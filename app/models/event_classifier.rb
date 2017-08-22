class EventClassifier < ActiveRecord::Base
  belongs_to :classifier
  belongs_to :event, inverse_of: :event_classifiers

  validates :value, presence: true
end

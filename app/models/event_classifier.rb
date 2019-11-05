class EventClassifier < ApplicationRecord
  belongs_to :classifier
  belongs_to :event

  # do not allow the same categories on an event
  validates_uniqueness_of :classifier_id, scope: %i[event_id]

  has_paper_trail meta: { associated_id: :event_id, associated_type: 'Event' }

  validates :value, presence: true
  validates :value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def as_array
    [ classifier.name, value]
  end

  def to_s
    classifier.to_s + " (#{value} %)"
  end
end

class EventFeedback < ApplicationRecord
  belongs_to :event, counter_cache: true

  after_save :update_average

  validates :rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  scope :with_valid_rating, -> { where(rating: 1..5) }

  protected

  def update_average
    event.recalculate_average_feedback!
  end
end

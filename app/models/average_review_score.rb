class AverageReviewScore < ApplicationRecord
  belongs_to :event
  belongs_to :review_metric
  has_one :conference, through: :event

  validates :review_metric, presence: true, uniqueness: { scope: :event }
  validates :event, presence: true
end

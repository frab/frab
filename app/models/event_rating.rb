class EventRating < ApplicationRecord
  belongs_to :event
  has_one :conference, through: :event
  has_many :review_scores, dependent: :delete_all
  belongs_to :person

  after_save :update_average
  
  validates :event, presence: true
  validates :person, presence: true
  
  accepts_nested_attributes_for :review_scores, allow_destroy: true

  protected

  def update_average
    event.recalculate_average_rating!
  end
end

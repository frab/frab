class EventRating < ApplicationRecord
  belongs_to :event
  has_one :conference, through: :event
  belongs_to :person

  after_save :update_average
  after_destroy :update_average
  
  validates :event, presence: true
  validates :person, presence: true

  protected

  def update_average
    event.recalculate_average_rating!
  end
end

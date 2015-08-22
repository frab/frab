class EventRating < ActiveRecord::Base
  belongs_to :event, counter_cache: true
  belongs_to :person

  after_save :update_average

  validates_presence_of :rating

  validates :event, presence: true
  validates :person, presence: true

  protected

  def update_average
    self.event.recalculate_average_rating!
  end
end

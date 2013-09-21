class EventRating < ActiveRecord::Base

  belongs_to :event, counter_cache: true
  belongs_to :person

  after_save :update_average

  validates_presence_of :rating, message: "please enter a rating message"

  validates :event, presence: true
  validates :person, presence: true
  validate :one_rating_only, message: "you already rated this event"

  protected

  def update_average
    self.event.recalculate_average_rating!
  end

  def one_rating_only
    unless EventRating.where(event_id: self.event, person_id: self.person).count == 0
      self.errors.add(:person, "person already rated this event") 
    end
  end


end

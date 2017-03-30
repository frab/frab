class EventFeedback < ApplicationRecord
  belongs_to :event, counter_cache: true

  after_save :update_average

  validates_presence_of :rating

  protected

  def update_average
    event.recalculate_average_feedback!
  end
end

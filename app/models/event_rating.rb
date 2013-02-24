class EventRating < ActiveRecord::Base

  belongs_to :event, counter_cache: true
  belongs_to :person

  after_save :update_average

  protected

  def update_average
    self.event.recalculate_average_rating!
  end

end

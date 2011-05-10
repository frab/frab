class EventRating < ActiveRecord::Base

  belongs_to :event
  belongs_to :person

end

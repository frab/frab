class EventFeedback < ActiveRecord::Base

  belongs_to :event

  validates_presence_of :rating, :message => "please select a value"

end

class Event < ActiveRecord::Base

  has_many :event_attachments
  has_many :event_people
  has_many :people, :through => :event_people

end

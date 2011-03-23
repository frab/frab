class EventAttachment < ActiveRecord::Base

  belongs_to :event

  has_attached_file :attachment

  acts_as_audited :associated_with => :event

end

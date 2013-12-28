class EventAttachment < ActiveRecord::Base

  belongs_to :event

  has_attached_file :attachment

  validates_attachment_size :attachment, :less_than => 42.megabytes

  has_paper_trail meta: {associated_id: :event_id, associated_type: "Event"}

  scope :public, where(public: true)

end

class Room < ActiveRecord::Base

  belongs_to :conference
  has_many :events

  has_paper_trail meta: {associated_id: :conference_id, associated_type: "Conference"}

  default_scope -> { order(:rank) }

  scope :is_public, -> { where(public: true) }

  def to_s
    "Room: #{self.name}"
  end

end

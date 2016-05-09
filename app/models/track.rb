class Track < ActiveRecord::Base
  belongs_to :conference

  default_scope -> { order(:name) }

  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  def to_s
    "Track: #{self.name}"
  end
end

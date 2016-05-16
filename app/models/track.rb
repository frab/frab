class Track < ActiveRecord::Base
  belongs_to :conference

  default_scope -> { order(:name) }

  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  validates :color, format: { with: /\A[a-zA-Z0-9]*\z/ }

  def to_s
    "#{model_name.human}: #{self.name}"
  end
end

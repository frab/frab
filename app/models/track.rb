class Track < ApplicationRecord
  after_destroy :update_events

  belongs_to :conference
  has_many :events

  default_scope -> { order(:name) }

  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  validates :color, format: { with: /\A[a-zA-Z0-9]*\z/ }
  validates :name, presence: true
  validates :name, format: { without: /\|/ }

  def to_s
    "#{model_name.human}: #{name}"
  end

  private

  def update_events
    events.update(track_id: nil)
  end
end

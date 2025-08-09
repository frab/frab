class Track < ApplicationRecord
  extend Mobility

  after_destroy :update_events

  belongs_to :conference
  has_many :events

  translates :name, column_fallback: true

  default_scope -> { order(:name) }

  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  before_validation :normalize_color

  validates :color, format: { with: /\A[a-zA-Z0-9]*\z/ }
  validates :name, presence: true
  validates :name, format: { without: /\|/ }

  def self.ransackable_attributes(_auth_object = nil)
    ["color", "conference_id", "created_at", "id", "id_value", "name", "updated_at"]
  end

  def to_s
    "#{model_name.human}: #{name}"
  end

  private

  def normalize_color
    self.color = color.to_s.gsub(/\A#/, '') if color.present?
  end

  def update_events
    events.update(track_id: nil)
  end
end

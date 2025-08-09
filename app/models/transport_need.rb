class TransportNeed < ApplicationRecord
  belongs_to :person
  belongs_to :conference
  validates :at, presence: true

  TYPES = %w(bus shuttle).freeze

  default_scope { order('at ASC') }

  def self.ransackable_associations(auth_object = nil)
    ["conference", "person"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["at", "transport_type", "note", "created_at", "updated_at"]
  end
end

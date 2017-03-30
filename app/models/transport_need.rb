class TransportNeed < ApplicationRecord
  belongs_to :person
  belongs_to :conference
  validates :at, presence: true

  TYPES = %w(bus shuttle)

  default_scope { order('at ASC') }
end

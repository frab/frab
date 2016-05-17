class TransportNeed < ActiveRecord::Base
  belongs_to :person
  belongs_to :conference
  validates_presence_of :at

  TYPES = %w(bus shuttle)

  default_scope { order('at ASC') }
end

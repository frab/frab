class Conflict < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :person, optional: true
  belongs_to :conflicting_event, class_name: 'Event', foreign_key: 'conflicting_event_id', optional: true
end

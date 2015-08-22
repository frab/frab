class Conflict < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  belongs_to :conflicting_event, class_name: "Event", foreign_key: "conflicting_event_id"
end

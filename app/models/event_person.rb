class EventPerson < ActiveRecord::Base

  ROLES = [:coordinator, :submitter, :speaker, :moderator]
  STATES = [:canceled, :confirmed, :declined, :idea, :offer, :unclear]

  belongs_to :event
  belongs_to :person

  acts_as_audited :associated_with => :event

end

class EventPerson < ActiveRecord::Base

  ROLES = [:coordinator, :submitter, :speaker, :moderator]
  STATES = [:canceled, :confirmed, :declined, :idea, :offer, :unclear]

  belongs_to :event
  belongs_to :person

  acts_as_audited :associated_with => :event

  def confirm!
    self.role_state = "confirmed"
    if self.event.transition_possible? :confirm
      self.event.confirm!
    end
    self.save!
  end

  def to_s
    "Event person: #{self.person.full_name} (#{self.event_role})"
  end

end

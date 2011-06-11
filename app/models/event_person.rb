class EventPerson < ActiveRecord::Base

  ROLES = [:coordinator, :submitter, :speaker, :moderator]
  STATES = [:canceled, :confirmed, :declined, :idea, :offer, :unclear]

  belongs_to :event
  belongs_to :person

  acts_as_audited :associated_with => :event

  def confirm!
    self.role_state = "confirmed"
    self.confirmation_token = nil
    if self.event.transition_possible? :confirm
      self.event.confirm!
    end
    self.save!
  end

  def generate_token!
    loop do
      token = Devise.friendly_token
      if EventPerson.find_by_confirmation_token(token)
        next
      else
        self.update_attributes!(:confirmation_token => token)
        break token
      end
    end
  end

  def available_between?(start_time, end_time)
    availability = self.person.availabilities.where(:conference_id => self.event.conference.id, :day => start_time.to_date).first
    if availability
      unless (availability.within_range?(start_time) and availability.within_range?(end_time))
        return false
      end
    end
    true
  end

  def to_s
    "Event person: #{self.person.full_name} (#{self.event_role})"
  end

end

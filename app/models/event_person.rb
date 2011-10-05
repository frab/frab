class EventPerson < ActiveRecord::Base
  include UniqueToken

  ROLES = [:coordinator, :submitter, :speaker, :moderator]
  STATES = [:canceled, :confirmed, :declined, :idea, :offer, :unclear]

  belongs_to :event
  belongs_to :person

  has_paper_trail :meta => {:associated_id => :event_id, :associated_type => "Event"}

  def confirm!
    self.role_state = "confirmed"
    self.confirmation_token = nil
    if self.event.transition_possible? :confirm
      self.event.confirm!
    end
    self.save!
  end

  def generate_token!
     generate_token_for(:confirmation_token)
     save
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

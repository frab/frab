class EventPerson < ActiveRecord::Base
  include UniqueToken

  ROLES = [:coordinator, :submitter, :speaker, :moderator]
  STATES = [:canceled, :confirmed, :declined, :idea, :offer, :unclear]

  belongs_to :event
  belongs_to :person
  after_save :update_speaker_count
  after_destroy :update_speaker_count

  has_paper_trail meta: {associated_id: :event_id, associated_type: "Event"}

  scope :presenter, where(event_role: ["speaker", "moderator"])

  def update_speaker_count
    event = Event.find(self.event_id)
    event.speaker_count = EventPerson.where(event_id: event.id, event_role: [:moderator, :speaker]).count
    event.save
  end

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
    return unless start_time and end_time
    self.person.availabilities.any? { |a| a.within_range? (start_time) and
                                         a.within_range? (end_time) }
  end

  def to_s
    "Event person: #{self.person.full_name} (#{self.event_role})"
  end

end

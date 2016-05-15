class EventPerson < ActiveRecord::Base
  include UniqueToken

  ROLES = [:coordinator, :submitter, :speaker, :moderator]
  STATES = [:canceled, :confirmed, :declined, :idea, :offer, :unclear, :attending]

  belongs_to :event
  belongs_to :person
  after_save :update_speaker_count
  after_destroy :update_speaker_count

  has_paper_trail meta: { associated_id: :event_id, associated_type: 'Event' }

  scope :presenter, -> { where(event_role: %w(speaker moderator)) }

  def update_speaker_count
    event = Event.find(self.event_id)
    event.speaker_count = EventPerson.where(event_id: event.id, event_role: [:moderator, :speaker]).count
    event.save
  end

  def confirm!
    self.role_state = 'confirmed'
    self.confirmation_token = nil
    self.event.confirm! if self.event.transition_possible? :confirm
    self.save!
  end

  def generate_token!
    generate_token_for(:confirmation_token)
    save
  end

  def available_between?(start_time, end_time)
    return unless start_time and end_time
    conference = self.event.conference
    availabilities = self.person.availabilities_in(conference)
    availabilities.any? { |a| a.within_range?(start_time) && a.within_range?(end_time) }
  end
end

class EventPerson < ActiveRecord::Base
  include UniqueToken
  include Rails.application.routes.url_helpers

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

  def set_default_notification
    conference = self.event.conference
    locale = self.person.locale_for_mailing(conference)
    notification = conference.notifications.with_locale(locale).first
    fail "Notification for #{locale} not found" if notification.nil?

    self.notification_subject = notification['accept_subject'] unless notification_subject.present?
    self.notification_body = notification['accept_body'] unless notification_body.present?
    save
  end

  def substitute_notification_variables(state, field)
    conference = self.event.conference
    locale = self.person.locale_for_mailing(conference)

    if field == :subject and self.notification_subject.present?
      string = self.notification_subject
      self.notification_subject = nil
      save
    elsif field == :body and self.notification_body.present?
      string = self.notification_body
      self.notification_body = nil
      save
    else
      notification = conference.notifications.with_locale(locale).first
      fail "Notification for #{locale} not found" if notification.nil?
      string = notification[state + '_' + field.to_s]
      fail "Field #{state}_#{field.to_s} not found" unless string.present?
    end

    string = string.gsub '%{conference}', conference.title
    string = string.gsub '%{event}', self.event.title
    string = string.gsub '%{forename}', self.person.first_name.presence || ''
    string = string.gsub '%{surname}', self.person.last_name.presence || ''
    string = string.gsub '%{public_name}', self.person.public_name.presence || ''

    string = string.gsub '%{room}', self.event.room.name if self.event.room.present?
    if self.event.start_time.present?
      string = string.gsub '%{date}', I18n.l(self.event.start_time.to_date, locale: locale)
      string = string.gsub '%{time}', I18n.l(self.event.start_time.to_time, locale: locale, format: '%X') 
    end

    return string unless self.confirmation_token.present?

    # XXX ENV.fetch('FRAB_HOST') does not belong here
    string.gsub '%{link}', cfp_event_confirm_by_token_url( conference_acronym: conference.acronym, id: self.event.id, token: self.confirmation_token, host: ENV.fetch('FRAB_HOST'), locale: locale )
  end

  def to_s
    "#{model_name.human}: #{self.person.full_name} (#{self.event_role})"
  end
end

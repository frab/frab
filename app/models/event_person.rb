class EventPerson < ApplicationRecord
  include UniqueToken
  include Rails.application.routes.url_helpers

  ROLES = %i(coordinator submitter speaker moderator).freeze
  STATES = %i(canceled confirmed declined idea offer unclear attending).freeze
  SPEAKER = %i(speaker moderator).freeze

  belongs_to :event
  belongs_to :person
  after_save :update_speaker_count
  after_destroy :update_speaker_count

  has_paper_trail meta: { associated_id: :event_id, associated_type: 'Event' }

  scope :presenter, -> { where(event_role: SPEAKER) }
  scope :presenter_at, ->(conference) {
    joins(event: :conference).where('conferences.id': conference).where('event_people.event_role': EventPerson::SPEAKER)
  }

  def update_speaker_count
    event = Event.find(event_id)
    event.speaker_count = EventPerson.where(event_id: event.id, event_role: SPEAKER).count
    event.save
  end

  def confirm!
    self.role_state = 'confirmed'
    self.confirmation_token = nil
    event.confirm! if event.transition_possible? :confirm
    save!
  end

  def generate_token!
    generate_token_for(:confirmation_token)
    save
  end

  def available_between?(start_time, end_time)
    return unless start_time and end_time
    conference = event.conference
    availabilities = person.availabilities_in(conference)
    availabilities.any? { |a| a.within_range?(start_time) && a.within_range?(end_time) }
  end

  def set_default_notification(state)
    conference = event.conference
    locale = person.locale_for_mailing(conference)
    notification = conference.notifications.with_locale(locale).first
    fail "Notification for #{locale} not found" if notification.nil?

    self.notification_subject = notification[state + '_subject'] unless notification_subject.present?
    self.notification_body = notification[state + '_body'] unless notification_body.present?
    save
  end

  def substitute_notification_variables(state, field)
    conference = event.conference
    locale = person.locale_for_mailing(conference)

    if field == :subject and notification_subject.present?
      string = notification_subject
      self.notification_subject = nil
      save
    elsif field == :body and notification_body.present?
      string = notification_body
      self.notification_body = nil
      save
    else
      notification = conference.notifications.with_locale(locale).first
      fail "Notification for #{locale} not found" if notification.nil?
      string = notification[state + '_' + field.to_s]
      fail "Field #{state}_#{field} not found" unless string.present?
    end

    string = string.gsub '%{conference}', conference.title
    string = string.gsub '%{event}', event.title
    string = string.gsub '%{forename}', person.first_name.presence || ''
    string = string.gsub '%{surname}', person.last_name.presence || ''
    string = string.gsub '%{public_name}', person.public_name.presence || ''

    string = string.gsub '%{room}', event.room.name if event.room.present?
    if event.start_time.present?
      string = string.gsub '%{date}', I18n.l(event.start_time.to_date, locale: locale)
      string = string.gsub '%{time}', I18n.l(event.start_time.to_time, locale: locale, format: '%X')
    end

    return string unless confirmation_token.present?

    # XXX ENV.fetch('FRAB_HOST') does not belong here
    string.gsub '%{link}', cfp_event_confirm_by_token_url(conference_acronym: conference.acronym, id: event.id, token: confirmation_token, host: ENV.fetch('FRAB_HOST'), locale: locale)
  end

  def to_s
    "#{model_name.human}: #{person.full_name} (#{event_role})"
  end
end

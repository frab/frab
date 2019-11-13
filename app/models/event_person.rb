class EventPerson < ApplicationRecord
  include UniqueToken
  include Rails.application.routes.url_helpers

  ROLES = %i(coordinator submitter speaker moderator assistant).freeze
  STATES = %i(canceled confirmed declined idea offer unclear attending).freeze
  SPEAKERS = %i(speaker moderator).freeze
  SUBSCRIBERS = %i(speaker moderator assistant).freeze
  JOINABLES = %i(speaker assistant).freeze

  belongs_to :event
  belongs_to :person
  has_one :conference, through: :event
  after_save :update_speaker_count
  after_save :update_event_conflicts
  after_destroy :update_speaker_count

  has_paper_trail meta: { associated_id: :event_id, associated_type: 'Event' }

  scope :presenter, -> { where(event_role: SPEAKERS) }
  scope :subscriber, -> { where(event_role: SUBSCRIBERS) }
  scope :presenter_at, ->(conference) {
    joins(event: :conference).where('conferences.id': conference).where('event_people.event_role': EventPerson::SPEAKERS)
  }

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
    raise Errors::NotificationMissingException, "Notification for #{locale} not found" if notification.nil?

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

    substitute_variables(string)
  end
  
  def substitute_variables(s)
    locale = person.locale_for_mailing(event.conference)
    string = s.gsub '%{conference}', conference.title
    string.gsub! '%{event}', event.title
    string.gsub! '%{event_id}', event.id.to_s
    string.gsub! '%{subtitle}', event.subtitle || ''
    string.gsub! '%{type}', event.localized_event_type(locale)
    string.gsub! '%{track}', event.track_name || ''
    string.gsub! '%{forename}', person.first_name.presence || ''
    string.gsub! '%{surname}', person.last_name.presence || ''
    string.gsub! '%{public_name}', person.public_name.presence || ''

    string.gsub! '%{room}', event.room.name if event.room.present?
    if event.start_time.present?
      string.gsub! '%{date}', event.start_time.in_time_zone(conference&.timezone).strftime('%F')
      string.gsub! '%{time}', event.start_time.in_time_zone(conference&.timezone).strftime('%H:%M %z %Z')
    end
    
    
    joinlink = cfp_events_join_url(token: event.invite_token, locale: locale) if event.invite_token.present?
    string.gsub! '%{joinlink}',  joinlink || '-'

    conflink = cfp_event_confirm_by_token_url(id: event.id, token: confirmation_token, locale: locale) if confirmation_token.present?
    string.gsub! '%{link}', conflink || '-'
    
    return string
    
  end

  def default_url_options
    result = { protocol: ENV.fetch('FRAB_PROTOCOL'),
               host: ENV.fetch('FRAB_HOST'), 
               port: ENV['FRAB_PORT'].presence }
    result[:conference_acronym] = conference.acronym if conference
    result
  end
  
  def to_s
    "#{model_name.human}: #{person.full_name} (#{event_role})"
  end

  private

  def update_speaker_count
    event.speaker_count = EventPerson.where(event_id: event.id, event_role: SPEAKERS).count
    event.save
  end

  def update_event_conflicts
    event.update_speaker_conflicts(self)
  end
end

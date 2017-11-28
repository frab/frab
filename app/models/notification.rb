class Notification < ApplicationRecord
  belongs_to :conference

  validates :locale, presence: true
  validates :reject_subject, presence: true
  validates :reject_body,    presence: true
  validates :accept_subject, presence: true
  validates :accept_body,    presence: true
  validates :schedule_subject, presence: true
  validates :schedule_body, presence: true
  validate :uniq_locale
  # TODO
  # validate :locale_is_valid

  scope :with_locale, ->(code) { where(arel_table[:locale].eq(code)) }

  VARIABLES = {
    'conference'  => I18n.t('conferences_module.variables.conference'),
    'public_name' => I18n.t('conferences_module.variables.public_name'),
    'forename'    => I18n.t('conferences_module.variables.forename'),
    'surname'     => I18n.t('conferences_module.variables.surname'),
    'event'       => I18n.t('conferences_module.variables.event'),
    'link'        => I18n.t('conferences_module.variables.link'),
    'date'        => I18n.t('conferences_module.variables.date'),
    'time'        => I18n.t('conferences_module.variables.time'),
    'room'        => I18n.t('conferences_module.variables.room')
  }.freeze

  def default_text=(locale = self.locale)
    return if locale.blank?
    I18n.locale = locale

    self.reject_subject = I18n.t('emails.event_rejection.subject')
    self.reject_body = <<-BODY
#{I18n.t('emails.event_rejection.greeting')}

#{I18n.t('emails.event_rejection.rejection')}
#{I18n.t('emails.event_rejection.goodbye')}
BODY

    self.accept_subject = I18n.t('emails.event_acceptance.subject')
    self.accept_body = <<-BODY
#{I18n.t('emails.event_acceptance.greeting')}

#{I18n.t('emails.event_acceptance.accepted_event')}
#{I18n.t('emails.event_acceptance.confirmation')}
#{I18n.t('emails.event_acceptance.check_data')}
#{I18n.t('emails.event_acceptance.goodbye')}
    BODY

    self.schedule_subject = I18n.t('emails.event_schedule.subject')
    self.schedule_body = <<-BODY
#{I18n.t('emails.event_schedule.greeting')}
#{I18n.t('emails.event_schedule.info')}
#{I18n.t('emails.event_schedule.goodbye')}
BODY
  end

  private

  def uniq_locale
    return if conference.nil?
    conference.notifications.each { |n|
      if n.id != id and n.locale == locale
        errors.add(:locale, "#{n.locale} already added to this cfp")
      end
    }
  end
end

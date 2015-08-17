class Notification < ActiveRecord::Base
  belongs_to :conference

  validates :locale, presence: true
  validates :reject_subject, presence: true
  validates :reject_body,    presence: true
  validates :accept_body,    presence: true
  validates :accept_subject, presence: true
  validate :uniq_locale
  # TODO
  # validate :locale_is_valid

  scope :with_locale, ->(code) { where(self.arel_table[:locale].eq(code)) }

  VARIABLES = {
    'conference'  => 'Conference name',
    'public_name' => 'Speaker public name',
    'forename'    => 'Speaker forename',
    'surname'     => 'Speaker surname',
    'event'       => 'Event title',
    'link'        => 'Confirmation link'
  }

  def default_text=(locale = self.locale)
    return if locale.nil?
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

    self.accept_subject = I18n.t('emails.event_acceptance.subject')
  end

  private

  def uniq_locale
    return if self.conference.nil?
    self.conference.notifications.each { |n|
      if n.id != self.id and n.locale == self.locale
        self.errors.add(:locale, "#{n.locale} already added to this cfp")
      end
    }
  end
end

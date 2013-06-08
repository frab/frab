class Notification < ActiveRecord::Base
  belongs_to :call_for_papers

  validates :reject_subject, presence: true
  validates :reject_body,    presence: true
  validates :accept_body,    presence: true
  validates :accept_subject, presence: true
  validate :uniq_locale, message: "this locale already exists for this call for papers"

  VARIABLES = {
      'conference'  => 'Conference name',
      'public_name' => 'Speaker public name',
      'forename'    => 'Speaker forename',
      'surname'     => 'Speaker surname',
      'public_name' => 'Speaker public name',
      'event'       => 'Event title',
      'link'        => 'Confirmation link',
  }

  # FIXME move to view helper
  # Setting default text current event notification is nil.
  def set_default_text( language )
    I18n.locale = language.code

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
    return if self.call_for_papers.nil?
    self.call_for_papers.notifications.each { |n|
      self.errors.add(:locale, "Locale #{n.locale} already added to this cfp") if self.locale == n.locale
    }
  end

end

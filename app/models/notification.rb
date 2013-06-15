class Notification < ActiveRecord::Base
  translates :reject_subject, :reject_body, :accept_body, :accept_subject

  belongs_to :call_for_participation

  validates :reject_subject, presence: true
  validates :reject_body,    presence: true
  validates :accept_body,    presence: true
  validates :accept_subject, presence: true

  VARIABLES = {
      'conference'  => 'Conference name',
      'public_name' => 'Speaker public name',
      'forename'    => 'Speaker forename',
      'surname'     => 'Speaker surname',
      'public_name' => 'Speaker public name',
      'event'       => 'Event title',
      'link'        => 'Confirmation link',
  }

  # Define reader and writer methods for supported locales
  #
  # Example:
  #
  #   call_for_participation_notification.reject_subject_en = 'Your submission to %{title}'
  #   call_for_participation_notification.event_state.reject_body_en
  translated_attribute_names.each do |attribute|
    I18n.available_locales.each do |locale|
      define_method "#{attribute}_#{locale}" do
        read_attribute(attribute, locale: locale)
      end

      define_method "#{attribute}_#{locale}=" do |value|
        write_attribute(attribute, value, locale: locale)
      end
    end
  end

  # Setting default text current event notification is nil.
  def setting_default_text( languages )
    languages.each do |language|
      I18n.locale = language.code

      self.reject_subject = I18n.t('emails.event_rejection.subject')
      self.reject_body = <<BODY
#{I18n.t('emails.event_rejection.greeting')}

#{I18n.t('emails.event_rejection.rejection')}
#{I18n.t('emails.event_rejection.goodbye')}
BODY

      self.accept_subject = I18n.t('emails.event_acceptance.subject')
      self.accept_body = <<BODY
#{I18n.t('emails.event_acceptance.greeting')}

#{I18n.t('emails.event_acceptance.accepted_event')}
#{I18n.t('emails.event_acceptance.confirmation')}
#{I18n.t('emails.event_acceptance.check_data')}
#{I18n.t('emails.event_acceptance.goodbye')}
BODY

      self.accept_subject = I18n.t('emails.event_acceptance.subject')
    end
  end
end
class SelectionNotification < ActionMailer::Base
 
  default :from => Settings['from_email']
  
  def acceptance_notification(event_person)
    @person = event_person.person
    @event = event_person.event
    @conference = @event.conference
    @locale = @person.locale_for_mailing(@conference)
    @token = event_person.confirmation_token
    mail(
      :reply_to => @conference.email,
      :to => event_person.person.email,
      :subject => t("emails.event_acceptance.subject", :locale => @locale, :title => @conference.title)
    )
  end

  def rejection_notification(event_person)
    @person = event_person.person
    @event = event_person.event
    @conference = @event.conference
    @locale = @person.locale_for_mailing(@conference)
    mail(
      :reply_to => @conference.email,
      :to => @person.email,
      :subject => t("emails.event_rejection.subject", :locale => @locale, :title => @conference.title)
    )
  end

end

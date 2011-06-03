class SelectionNotification < ActionMailer::Base
 
  def acceptance_notification(event_person)
    @person = event_person.person
    @event = event_person.event
    @conference = @event.conference
    @locale = @person.locale_for_mailing(@conference)
    @token = event_person.confirmation_token
    mail(
      :from => @conference.email,
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
      :from => @conference.email,
      :to => @person.email,
      :subject => t("emails.event_rejection.subject", :locale => @locale, :title => @conference.title)
    )
  end

end

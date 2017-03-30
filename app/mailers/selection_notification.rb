class SelectionNotification < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL')

  def make_notification(event_person, field)
    @locale = event_person.person.locale_for_mailing(event_person.event.conference)
    @body = event_person.substitute_notification_variables(field, :body)
    conference = event_person.event.conference

    mail(
      reply_to: conference.email,
      to: event_person.person.email,
      subject: event_person.substitute_notification_variables(field, :subject),
      locale: @locale,
      title: conference.title
    )
  end
end

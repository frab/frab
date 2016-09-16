class SelectionNotification < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL')

  def common_notification(event_person, field)
    @locale = event_person.person.locale_for_mailing(event_person.event.conference)
    @body = event_person.substitute_notification_variables(field + '_body')
    conference = event_person.event.conference

    mail(
      reply_to: conference.email,
      to: event_person.person.email,
      subject: event_person.substitute_notification_variables(field + '_subject'),
      locale: @locale,
      title: conference.title
    )
  end

  def acceptance_notification(event_person)
    common_notification(event_person, 'accept')
  end

  def rejection_notification(event_person)
    common_notification(event_person, 'reject')
  end

  def schedule_notification(event_person)
    common_notification(event_person, 'schedule')
  end
end

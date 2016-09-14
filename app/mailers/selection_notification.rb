class SelectionNotification < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL')

  def common_notification(event_person)
    @event_person = event_person
    conference = event_person.event.conference
    @locale = event_person.person.locale_for_mailing(conference)
    @notification = conference.notifications.with_locale(@locale).first
    fail "Notification for #{@locale} not found" if @notification.nil?

    mail(
      reply_to: conference.email,
      to: event_person.person.email,
      subject: event_person.substitute_notification_variables(yield @notification),
      locale: @locale,
      title: conference.title
    )
  end

  def acceptance_notification(event_person)
    common_notification(event_person) { |notification| notification.accept_subject }
  end

  def rejection_notification(event_person)
    common_notification(event_person) { |notification| notification.reject_subject }
  end

  def schedule_notification(event_person)
    common_notification(event_person) { |notification| notification.schedule_subject }
  end
end

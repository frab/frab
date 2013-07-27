class SelectionNotification < ActionMailer::Base
 
  default from: Settings['from_email']
  
  def acceptance_notification(event_person)
    @person = event_person.person
    @event = event_person.event
    @conference = @event.conference
    @token = event_person.confirmation_token
    @locale = @person.locale_for_mailing(@conference)
    @notification = @conference.call_for_papers.notifications.with_locale(@locale).first
    raise "Notification for #{@locale} not found" if @notification.nil?

    mail(
      reply_to: @conference.email,
      to: event_person.person.email,
      subject: @notification.accept_subject.gsub('%{conference}', @conference.title).gsub('%{event}', @event.title).gsub('%{forename}', @person.first_name).gsub('%{surname}', @person.last_name).gsub('%{public_name}', @person.public_name), locale: @locale, title: @conference.title
    )
  end

  def rejection_notification(event_person)
    @person = event_person.person
    @event = event_person.event
    @conference = @event.conference
    @locale = @person.locale_for_mailing(@conference)
    @notification = @conference.call_for_papers.notifications.with_locale(@locale).first
    raise "Notification for #{@locale} not found" if @notification.nil?

    mail(
      reply_to: @conference.email,
      to: @person.email,
      subject: @notification.accept_subject.gsub('%{conference}', @conference.title).gsub('%{event}', @event.title).gsub('%{forename}', @person.first_name).gsub('%{surname}', @person.last_name).gsub('%{public_name}', @person.public_name), locale: @locale, title: @conference.title
    )
  end

end

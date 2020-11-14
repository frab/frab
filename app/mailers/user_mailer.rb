class UserMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL')

  def password_reset_instructions(user, conference)
    @user = user
    @conference = conference
    mail to: @user.email, subject: I18n.t('mailers.user_mailer.password_reset_instructions')
  end

  def confirmation_instructions(user, conference = nil)
    @user = user
    @conference = conference
    mail to: @user.email, subject: I18n.t('mailers.user_mailer.confirmation_instructions')
  end

  def bulk_mail_multiple_roles(event_people, template)
    return if event_people.empty?
    persons=event_people.pluck(:person_id).uniq
    raise "this function should be used for one person only" unless persons.count == 1
    person=Person.find(persons.first)

    bcc = template.conference.bcc_address
    
    msgs=event_people.map{|event_person| template.message_text_for_event_person(event_person)}
    msgs.uniq.each do |msg|
      mail to: person.email, subject: msg[:subject], body: msg[:body], bcc: bcc
    end
  end
end

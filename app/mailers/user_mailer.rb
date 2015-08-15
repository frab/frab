class UserMailer < ActionMailer::Base

  default from: Settings['from_email']

  def password_reset_instructions(user, conference)
    @user = user
    @conference = conference
    mail to: @user.email, subject: I18n.t("mailers.user_mailer.password_reset_instructions")
  end

  def confirmation_instructions(user, conference=nil)
    @user = user
    @conference = conference
    mail to: @user.email, subject: I18n.t("mailers.user_mailer.confirmation_instructions")
  end

end

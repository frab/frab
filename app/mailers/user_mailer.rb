class UserMailer < ActionMailer::Base

  default from: ENV.fetch("FROM_EMAIL")

  def password_reset_instructions(user)
    @user = user
    mail to: @user.email, subject: I18n.t("mailers.user_mailer.password_reset_instructions")
  end

  def confirmation_instructions(user)
    @user = user
    mail to: @user.email, subject: I18n.t("mailers.user_mailer.confirmation_instructions")
  end

end

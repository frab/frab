class UserMailer < ActionMailer::Base

  default :from => Settings['from_email']

  def password_reset_instructions(user)
    @user = user
    mail :to => @user.email, :subject => I18n.t(:password_reset_instructions)
  end

  def confirmation_instructions(user)
    @user = user
    mail :to => @user.email, :subject => I18n.t(:confirmation_instructions)
  end

end

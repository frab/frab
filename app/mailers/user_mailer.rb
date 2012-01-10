class UserMailer < ActionMailer::Base

  default :from => Settings['from_email']

  def password_reset_instructions(user)
    @user = user
    mail :to => @user.email
  end

  def confirmation_instructions(user)
    @user = user
    mail :to => @user.email
  end

end

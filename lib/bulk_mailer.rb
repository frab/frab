class BulkMailer
  def initialize(subject, from, mail_file, body_file, force = false)
    @subject = subject
    @from_email = from
    @force = force
    @emails = File.readlines(mail_file).collect(&:chomp)
    @body = File.read(body_file)

    @emails.each { |email|
      send_mail_to(email)
    }
  end

  private

  class BulkMail < ActionMailer::Base
    def notify(template, person, args)
      puts "send mail to: #{args[:to]}"
      @person = person
      mail(args) do |format|
        format.text { render inline: template }
      end
    end
  end

  def send_mail_to(email)
    p = Person.find_by_email(email)
    email_address_with_name = p.nil? ? email : "#{p.public_name} <#{email}>"

    if p.nil?
      email_address_with_name = email
    else
      email_address_with_name = "#{p.public_name} <#{email}>"
    end

    unless @force
      unless p.include_in_mailings?
        puts "skipped due to settings: #{email}"
        return
      end
    end

    args = { subject: @subject, to: email_address_with_name, from: @from_email }

    BulkMail.notify(@body, p, args).deliver
  end
end

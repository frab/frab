namespace :frab do

  PASSWORD='frab123'
  MAIL_DOMAIN="localhost.localdomain"
  MAIL_USER="root"

  task :default => :add_example_users

  desc "add example users for testing (use: mail_user=root mail_domain=localhost.localdomain password=frab123)"
  task :add_example_users => :environment do |t,args|
    mail_user = ENV['mail_user'] || MAIL_USER
    mail_domain = ENV['mail_domain'] || MAIL_DOMAIN
    password = ENV['password'] || PASSWORD

    PaperTrail.enabled = false
    %w{admin orga coordinator reviewer submitter}.each do |role|
      puts "create user #{mail_user}+#{role}@#{mail_domain} with password #{password}"
      create_user role, get_mail(mail_user, role, mail_domain)
    end
  end

  desc "reset all user passwords for development"
  task :reset_all_passwords => :environment do |t,args|
    password = ENV['password'] || PASSWORD
    PaperTrail.enabled = false
    User.all.each do |user|
      user.password = password
      user.save
    end
    puts "set #{User.all.count} passwords to #{password}"
  end

  def get_mail(user, role, domain)
    "#{user}+#{role}@#{domain}"
  end

  def create_user(role, email)
    person = Person.create!(
      email: email,
      public_name: role,
    )

    user = User.new(
      email: person.email,
      password: PASSWORD,
      password_confirmation: PASSWORD,
    )
    user.person = person
    user.role = role
    user.confirmed_at = Time.now
    user.save!
  end

end

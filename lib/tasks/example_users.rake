namespace :frab do
  PASSWORD = 'frab123'
  MAIL_DOMAIN = 'localhost.localdomain'
  MAIL_USER = 'root'

  task default: :add_example_users

  desc 'add example users for testing (use: mail_user=root mail_domain=localhost.localdomain password=frab123)'
  task add_example_users: :environment do |_t, _args|
    mail_user = ENV['mail_user'] || MAIL_USER
    mail_domain = ENV['mail_domain'] || MAIL_DOMAIN
    password = ENV['password'] || PASSWORD

    PaperTrail.enabled = false
    ActiveRecord::Base.transaction do
      conference = Conference.first
      if not conference.present?
        puts 'No conference crew created, since no conference exists'
        # create full admin
        email = get_mail(mail_user, 'admin', mail_domain)
        create_user email, 'admin', password
      else
        puts "Creating crew for conference #{conference.acronym}"
        %w(orga coordinator reviewer).each do |crew_role|
          email = get_mail(mail_user, "crew.#{crew_role}", mail_domain)
          user_id = create_user email, 'crew', password
          add_conference_rights(user_id, conference.id, crew_role)
        end
      end
    end
  end

  desc 'reset all user passwords for development'
  task reset_all_passwords: :environment do |_t, _args|
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

  def create_user(email, role, password)
    puts "create user #{email} with password #{password}"

    person = Person.create!(
      email: email,
      public_name: role
    )

    user = User.new(
      email: person.email,
      password: password,
      password_confirmation: password
    )
    user.person = person
    user.role = role
    user.confirmed_at = Time.now
    user.save!
    user.id
  end

  def add_conference_rights(user_id, conference_id, crew_role)
    ConferenceUser.create! user_id: user_id, conference_id: conference_id, role: crew_role
  end
end

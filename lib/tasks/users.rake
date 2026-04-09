namespace :frab do
  desc "List admin and management users"
  task list_management_users: :environment do
    def truncate(text, max)
      return text if text.length <= max
      "#{text[0...(max - 1)]}…"
    end

    header = "%-40s | %-25s | %-12s | %s" % ["Email", "Name", "Global Role", "Conference Roles"]
    puts header
    puts "-" * header.length

    # Admins and Crew users (who might have conference roles)
    users = User.where(role: %w(admin crew)).includes(:person, conference_users: :conference)

    users.find_each do |user|
      conference_roles = user.conference_users.map { |cu| "#{cu.conference.acronym}: #{cu.role}" }.join(", ")
      
      # List if admin or has any conference-specific role (management/crew)
      should_list = user.is_admin? || user.conference_users.any?
      
      if should_list
        puts "%-40s | %-25s | %-12s | %s" % [
          truncate(user.email, 40),
          truncate(user.person&.public_name || "N/A", 25),
          user.role,
          conference_roles.presence || "None"
        ]
      end
    end
  end
end

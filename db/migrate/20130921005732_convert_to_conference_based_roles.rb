class ConvertToConferenceBasedRoles < ActiveRecord::Migration
  def up
    User.where(role: %w{orga coordinator reviewer}).each { |user|
      user.role = 'crew'
      user.save
    }
  end

  def down
    User.where(role: 'crew').each { |user|
      user.role = 'reviewer'
      user.save
    }
  end
end

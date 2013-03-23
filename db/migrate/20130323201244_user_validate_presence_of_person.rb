class UserValidatePresenceOfPerson < ActiveRecord::Migration
  def up
    users = User.all.select { |u| u.person.nil? }
    users.each { |user|
      user.person = Person.new(email: user.email, public_name: user.email)
      user.save!
    }
  end

  def down
  end
end

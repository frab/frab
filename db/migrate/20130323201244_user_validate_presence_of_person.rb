class UserValidatePresenceOfPerson < ActiveRecord::Migration
  def up
    users = User.all.select { |u| u.person.nil? }
    users.each { |user|
      User.transaction do
        person = Person.new(user_id: user.id, email: user.email, public_name: "empty")
        person.save!
        user.person = person
        user.save!
      end
    }
  end

  def down
  end
end

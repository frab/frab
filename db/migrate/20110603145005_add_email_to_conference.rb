class AddEmailToConference < ActiveRecord::Migration
  def self.up
    add_column :conferences, :email, :string
  end

  def self.down
    remove_column :conferences, :email
  end
end

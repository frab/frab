class AddUserToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :user_id, :integer
  end

  def self.down
    remove_column :people, :user_id
  end
end

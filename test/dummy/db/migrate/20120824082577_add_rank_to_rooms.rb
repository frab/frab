class AddRankToRooms < ActiveRecord::Migration
  def self.up
    add_column :rooms, :rank, :integer
  end

  def self.down
    remove_column :rooms, :rank
  end
end

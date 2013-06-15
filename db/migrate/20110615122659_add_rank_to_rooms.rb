class AddRankToRooms < ActiveRecord::Migration
  def self.up
    add_column :rooms, :rank, :integer
    Room.reset_column_information
    # Undefined method? Room.disable_auditing
    Conference.all.each do |conference|
      i = 1
      conference.rooms.each do |room|
        room.update_attributes(rank: i)
        i += 1
      end
    end
  end

  def self.down
    remove_column :rooms, :rank
  end
end

class RemovePublicFromRooms < ActiveRecord::Migration
  def up
    remove_column :rooms, :public
  end
  def down
    add_column :rooms, :public, :boolean, default: true
  end
end

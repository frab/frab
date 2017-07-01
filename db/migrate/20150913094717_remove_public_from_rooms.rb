class RemovePublicFromRooms < ActiveRecord::Migration[4.2]
  def up
    remove_column :rooms, :public
  end
  def down
    add_column :rooms, :public, :boolean, default: true
  end
end

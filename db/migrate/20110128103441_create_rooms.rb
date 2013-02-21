class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.integer :conference_id, null: false
      t.string :name, null: false
      t.integer :size
      t.boolean :public, default: true

      t.timestamps
    end
  end

  def self.down
    drop_table :rooms
  end
end

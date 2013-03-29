class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :conference_id, null: false
      t.string :title, null: false
      t.string :subtitle
      t.string :event_type, default: "talk"
      t.integer :time_slots
      t.string :state, null: false, default: "undecided"
      t.string :progress, null: false, default: "new"
      t.string :language
      t.datetime :start_time
      t.text :abstract
      t.text :description
      t.boolean :public, default: true
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.integer :track_id
      t.integer :room_id

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end

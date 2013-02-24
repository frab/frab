class CreateConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.string :acronym, null: false
      t.string :title, null: false
      t.string :timezone, null: false, default: "Berlin"
      t.integer :timeslot_duration, null: false, default: 15
      t.integer :default_timeslots, null: false, default: 4
      t.integer :max_timeslots, null: false, default: 20
      t.date :first_day, null: false
      t.date :last_day, null: false
      t.boolean :feedback_enabled, null: false, default: false

      t.timestamps
    end
  end

  def self.down
    drop_table :conferences
  end
end

class CreateEventPeople < ActiveRecord::Migration
  def self.up
    create_table :event_people do |t|
      t.integer :event_id, null: false
      t.integer :person_id, null: false
      t.string :event_role, null: false, default: "submitter"
      t.string :role_state
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :event_people
  end
end

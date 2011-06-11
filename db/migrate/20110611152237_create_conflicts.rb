class CreateConflicts < ActiveRecord::Migration
  def self.up
    create_table :conflicts do |t|
      t.integer :event_id
      t.integer :conflicting_event_id
      t.integer :person_id
      t.string :conflict_type
      t.string :severity

      t.timestamps
    end
  end

  def self.down
    drop_table :conflicts
  end
end

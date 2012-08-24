class CreateEventRatings < ActiveRecord::Migration
  def self.up
    create_table :event_ratings do |t|
      t.integer :event_id
      t.integer :person_id
      t.float :rating
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :event_ratings
  end
end

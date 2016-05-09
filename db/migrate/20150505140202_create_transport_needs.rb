class CreateTransportNeeds < ActiveRecord::Migration
  def change
    create_table :transport_needs do |t|
      t.references :person
      t.references :conference
      t.datetime :at
      t.string :transport_type
      t.integer :seats
      t.boolean :booked
      t.text :note

      t.timestamps
    end
    add_index :transport_needs, :person_id
    add_index :transport_needs, :conference_id
  end
end

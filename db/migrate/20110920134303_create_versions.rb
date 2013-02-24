class CreateVersions < ActiveRecord::Migration
  def up
    create_table :versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.integer  :conference_id
      t.integer  :associated_id
      t.string  :associated_type
    end
    add_index :versions, [:item_type, :item_id]
  end

  def down
    remove_index :versions, [:item_type, :item_id]
    drop_table :versions
  end
end

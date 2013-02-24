class CreateEventAttachments < ActiveRecord::Migration
  def self.up
    create_table :event_attachments do |t|
      t.integer :event_id, null: false
      t.string :title, null: false
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :event_attachments
  end
end

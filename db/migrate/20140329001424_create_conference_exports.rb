class CreateConferenceExports < ActiveRecord::Migration
  def change
    create_table :conference_exports do |t|
      t.string :locale
      t.references :conference
      t.string :tarball_file_name
      t.string :tarball_content_type
      t.integer :tarball_file_size
      t.datetime :tarball_updated_at
      t.timestamps
    end
    add_index :conference_exports, :conference_id
  end
end

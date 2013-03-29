class NotesFields < ActiveRecord::Migration
  def up
    add_column :events, :note, :text
    add_column :events, :submission_note, :text
    add_column :people, :note, :text
  end

  def down
    remove_column :events, :note
    remove_column :events, :submission_note, :text
    remove_column :people, :note
  end
end

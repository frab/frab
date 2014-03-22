class IncreaseVersionObjectChangesSize < ActiveRecord::Migration
  def up
    change_column :versions, :object_changes, :text, limit: 4.megabytes
  end

  def down
    change_column :versions, :object_changes, :text
  end
end

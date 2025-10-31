class AddLockedToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :locked, :boolean, default: false
  end
end

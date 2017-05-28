class AddDefaultToEvents < ActiveRecord::Migration[5.0]
  def up
    change_column :events, :time_slots, :integer, default: 3
  end
  def down
    change_column :events, :time_slots, :integer
  end
end

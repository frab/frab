class AddEventStateVisibleToggle < ActiveRecord::Migration
  def change
    add_column :conferences, :event_state_visible, :boolean, default: true
  end
end

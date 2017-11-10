class AddScheduleOpenFlagToConferences < ActiveRecord::Migration[5.1]
  def change
    add_column :conferences, :schedule_open, :boolean, default: false, null: false
  end
end

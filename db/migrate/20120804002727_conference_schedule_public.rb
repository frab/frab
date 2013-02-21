class ConferenceSchedulePublic < ActiveRecord::Migration
  def up
    add_column :conferences, :schedule_public, :boolean, null: false, default: false
  end

  def down
    remove_column :conferences, :schedule_public
  end
end

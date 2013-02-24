class AddDayStartAndEndToConference < ActiveRecord::Migration
  def self.up
    add_column :conferences, :day_start, :time, null: false, default: "08:00"
    add_column :conferences, :day_end, :time, null: false, default: "20:00"
  end

  def self.down
    remove_column :conferences, :day_end
    remove_column :conferences, :day_start
  end
end

class AllowedEventTimeslotsLength < ActiveRecord::Migration[5.2]
  def change
    change_column :conferences, :allowed_event_timeslots_csv, :longtext
  end
end

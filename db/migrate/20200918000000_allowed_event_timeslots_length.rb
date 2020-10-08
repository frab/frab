class AllowedEventTimeslotsLength < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        change_column :conferences, :allowed_event_timeslots_csv, :string, :limit => 400
      end
      dir.down do
        nil
      end
    end
  end
end

class AddAllowedEventTimeslotsToConferences < ActiveRecord::Migration[5.2]
  def up

    # An old version of this migration might leave the DB in an unhealthy state
    if column_exists? :conferences, :allowed_event_timeslots_csv
      remove_column :conferences, :allowed_event_timeslots_csv
    end

    add_column :conferences, :allowed_event_timeslots_csv, :string, :limit => 400

    Conference.all.each do |conference|
      conference.update_attributes(allowed_event_timeslots: (1..conference.max_timeslots))
    end
  end

  def down
    remove_column :conferences, :allowed_event_timeslots_csv
  end
end

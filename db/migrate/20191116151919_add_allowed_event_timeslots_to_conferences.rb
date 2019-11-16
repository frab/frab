class AddAllowedEventTimeslotsToConferences < ActiveRecord::Migration[5.2]
  def up
    add_column :conferences, :allowed_event_timeslots_csv, :string
    
    Conference.all.each do |conference|
      conference.update_attributes(allowed_event_timeslots: (1..conference.max_timeslots))
    end
  end

  def down
    remove_column :conferences, :allowed_event_timeslots_csv
  end
end

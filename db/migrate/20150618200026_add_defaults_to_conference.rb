class AddDefaultsToConference < ActiveRecord::Migration
  def change
    change_column :conferences, :timeslot_duration, :integer, default: 15
    change_column :conferences, :ticket_type, :string, default: 'integrated'
    change_column :conferences, :default_timeslots, :integer, default: 3
  end
end

class AddDefaultsToSubConference < ActiveRecord::Migration[4.2]
  def change
    change_column :conferences, :max_timeslots, :integer, default: 20
    change_column :conferences, :timezone, :string, default: 'Berlin'
  end
end

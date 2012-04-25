class Change_conferenceDayStartType < ActiveRecord::Migration
  def up
    change_column :conferences, :day_start, :integer, :default => "8", :null => false
    change_column :conferences, :day_end, :integer, :default => "20", :null => false
    # try conversion
    Conference.all.each do |conference|
      conference.day_start = Time.at(conference.day_start).hour
    end
  end

  def down
    change_column :conferences, :day_start, :time, :default => '2000-01-01 08:00:00', :null => false
    change_column :conferences, :day_end, :time, :default => '2000-01-01 20:00:00', :null => false
  end
end

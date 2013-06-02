class ChangeConferenceDayStartType < ActiveRecord::Migration
  def up
    starts = Array.new
    ends = Array.new
    Conference.all.each do |conference|
      starts << Time.at(conference.day_start).hour
      ends << Time.at(conference.day_end).hour
    end
    change_column :conferences, :day_start, :integer, default: "8", null: false
    change_column :conferences, :day_end, :integer, default: "20", null: false
    # do conversion
    Conference.all.each_with_index do |conference,i|
      conference.update_attribute :day_start, starts[i]
      conference.update_attribute :day_end, ends[i]
    end
  end

  def down
    change_column :conferences, :day_start, :time, default: '2000-01-01 08:00:00', null: false
    change_column :conferences, :day_end, :time, default: '2000-01-01 20:00:00', null: false
  end
end

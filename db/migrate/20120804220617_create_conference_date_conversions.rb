class CreateConferenceDateConversions < ActiveRecord::Migration
  def up
    # convert conferences
    remove_column :conferences, :day_start
    remove_column :conferences, :day_end
    remove_column :conferences, :first_day
    remove_column :conferences, :last_day
    Conference.all.each do |conference|
      Time.zone = conference.timezone
      day = conference.attributes["first_day"]
      until (day > conference.attributes["last_day"])
        start_date = day.to_datetime.change(:hour => conference.attributes["day_start"])
        end_date = day.to_datetime.change(:hour => conference.attributes["day_end"])
        tmp = Day.new(:conference => conference,
                      :start_date => Time.zone.local_to_utc(start_date), 
                      :end_date => Time.zone.local_to_utc(end_date))
        tmp.save!
        day = day.since(1.days).to_date
      end
    end

    # convert people availabilities
    # remove_column :availabilities, :day
    # add_column :availabilities, :day_id, :integer
    # change_column :availabilities, :start_time, :datetime
    # change_column :availabilities, :end_time, :datetime
    # Availabilities.all.each do |a|
    #   Time.zone = a.conference.timezone
    #   a.start_time = a.day.to_datetime.change(:hour=>a.start_time.hour, :minute=>a.start_time.min)
    #   a.end_time = a.day.to_datetime.change(:hour=>a.end_time.hour, :minute=>a.end_time.min)
    #   TODO Availability belongs_to Day
    #   id = a.conference.days.select { |d| a.day.strftime("%Y-%m-%d") == d.start_date.strftime("%Y-%m-%d")  
    #   a.day_id = id
    # end
  end

  def down
  end
end

class CreateConferenceDateConversions < ActiveRecord::Migration
  def up
    # convert conferences
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
    remove_column :conferences, :day_start
    remove_column :conferences, :day_end
    remove_column :conferences, :first_day
    remove_column :conferences, :last_day
  end

  def down
  end
end

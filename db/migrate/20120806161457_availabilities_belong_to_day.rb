class AvailabilitiesBelongToDay < ActiveRecord::Migration
  def up

    # convert availability times
    add_column :availabilities, :start_date, :datetime
    add_column :availabilities, :end_date, :datetime
    # availability belongs_to Day
    add_column :availabilities, :day_id, :integer
    Availability.reset_column_information

    Availability.all.each do |a|
      Time.zone = a.conference.timezone

      if a.start_time.nil? or a.end_time.nil?
        # error in existing data, skip
        a.delete
        next
      end

      a.start_date = a.attributes["day"].to_datetime.change(
        hour: a.start_time.hour, minute: a.start_time.min)
      a.end_date = a.attributes["day"].to_datetime.change(
        hour: a.end_time.hour, minute: a.end_time.min)
      a.day_id = a.conference.days.select { |d| a.attributes["day"].strftime("%Y-%m-%d") == d.start_date.strftime("%Y-%m-%d") }.first.id

      if a.start_date >= a.end_date
        # not available at all, skip
        a.delete
        next
      end
      a.save!
    end

    remove_column :availabilities, :start_time
    remove_column :availabilities, :end_time
    remove_column :availabilities, :day

  end

  def down
    remove_column :availabilities, :start_date, :datetime
    remove_column :availabilities, :end_date, :datetime
    remove_column :availabilities, :day_id, :integer
    add_column :availabilities, :start_time, :datetime
    add_column :availabilities, :end_time, :datetime
    add_column :availabilities, :day, :integer
  end
end

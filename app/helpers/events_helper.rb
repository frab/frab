module EventsHelper

  def timeslots
    slots = Array.new
    @conference.max_timeslots.times do |i|
      duration_in_minutes = i * @conference.timeslot_duration
      minutes = sprintf("%02d", duration_in_minutes % 60)
      hours = sprintf("%02d", duration_in_minutes / 60)
      slots << ["#{hours}:#{minutes}", i]
    end
    slots
  end

  def start_times
    times = Array.new
    date = @conference.first_day
    while date <= @conference.last_day
      time = date.to_time
      time = time.since(7.hours)
      end_time = time.since(16.hours)
      while time <= end_time
        times << [time.strftime("%Y-%m-%d %H:%M"), time]
        time = time.since(@conference.timeslot_duration.minutes)
      end
      date = date.tomorrow
    end
    times
  end

end

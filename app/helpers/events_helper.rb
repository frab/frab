module EventsHelper

  def fix_http_proto(url)
    if url.start_with?('https') or url.start_with?('http') or url.start_with?('ftp')
      url
    else
      "http://#{url}"
    end
  end

  def timeslots
    slots = Array.new
    (@conference.max_timeslots+1).times do |i|
      slots << [format_time_slots(i), i]
    end
    slots
  end

  def start_times
    times = Array.new
    @conference.days.each { |day|
      time = day.start_date
      while time <= day.end_date
        times << [time.strftime("%Y-%m-%d %H:%M"), time]
        time = time.since(@conference.timeslot_duration.minutes)
      end
    }
    times
  end

  def format_time_slots(number_of_time_slots)
    duration_in_minutes = number_of_time_slots * @conference.timeslot_duration
    duration_to_time(duration_in_minutes)
  end

end

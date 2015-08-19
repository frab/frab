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

  def format_start_times(times)
    times.map { |t| [t.strftime("%Y-%m-%d %H:%M"), t] }
  end

  def format_time_slots(number_of_time_slots)
    duration_in_minutes = number_of_time_slots * @conference.timeslot_duration
    duration_to_time(duration_in_minutes)
  end

end

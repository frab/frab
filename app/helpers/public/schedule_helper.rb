module Public::ScheduleHelper

  def each_time_slot_of(day, &block)
    time = day.beginning_of_day.since(7.hours)
    while (time < day.end_of_day)
      yield time
      time = time.since(@conference.timeslot_duration.minutes)
    end
  end

  def track_class(event)
    if event.track
      "track-#{event.track.name.parameterize}"
    else
      "track-default"
    end
  end

end

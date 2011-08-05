module Public::ScheduleHelper

  def each_time_slot_of(day, &block)
    time = @conference.day_start
    while (time < @conference.day_end)
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

  def selected(regex)
    "selected" if request.path =~ regex
  end

end

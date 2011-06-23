module Public::ScheduleHelper

  def each_time_slot_of(day, &block)
    time = @conference.events.public.accepted.scheduled_on(day).order(:start_time).first.try(:start_time)
    while (time and time < day.end_of_day)
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

module Public::ScheduleHelper

  def each_timeslot(&block)
    each_minutes(@conference.timeslot_duration, &block)
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

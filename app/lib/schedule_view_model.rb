class ScheduleViewModel
  def initialize(conference)
    @conference = conference
  end

  def events
    @events ||= @conference.schedule_events.sort_by(&:to_sortable)
  end

  def events_by_track
    @events_by_track ||= events.group_by(&:track_id)
  end

  def events_by_day
    @conference.days.each_with_object({}) { |day, h|
      h[day] = @conference.schedule_events.scheduled_on(day).group_by(&:start_time)
    }
  end

  def event
    @event ||= @conference.schedule_events.find(@event_id)
  end

  def concurrent_events
    @concurrent_events ||= @conference.schedule_events.where(start_time: event.start_time)
  end

  def for_event(id)
    @event_id = id
    self
  end

  def speakers
    @speakers ||= Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).order(:public_name, :first_name, :last_name)
  end

  def speaker
    @speaker ||= Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).find(@speaker_id)
  end

  def for_speaker(id)
    @speaker_id = id
    self
  end
end

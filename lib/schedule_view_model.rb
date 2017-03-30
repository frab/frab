class ScheduleViewModel
  def initialize(conference)
    @conference = conference
  end

  def events
    @events ||= @conference.events_including_subs.is_public.confirmed.scheduled.sort_by(&:to_sortable)
  end

  def events_by_track
    @events_by_track ||= events.group_by(&:track_id)
  end

  def event
    @event ||= @conference.events_including_subs.is_public.confirmed.scheduled.find(@event_id)
  end

  def concurrent_events
    @concurrent_events ||= @conference.events_including_subs.is_public.confirmed.scheduled.where(start_time: event.start_time)
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

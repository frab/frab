class ScheduleViewModel
  def initialize(conference)
    @conference = conference
  end
  attr_reader :event, :speaker, :day

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

  def concurrent_events
    @concurrent_events ||= @conference.schedule_events.where(start_time: event.start_time)
  end

  def for_event(id)
    @event = @conference.schedule_events.find(id)
    self
  end

  def for_day(day)
    @day = day
    @events_by_room_cache = {}  # Reset cache when setting a new day
    self
  end

  def room_slices(&block)
    return enum_for(:room_slices) unless block_given?
    return [] unless @day&.rooms_with_events

    @day.rooms_with_events.each_slice(7) do |s|
      yield s
    end
  end

  def events_by_room(room)
    build_events_by_room unless @events_by_room

    # Return cached working copy for this rendering context
    @events_by_room_cache[room] ||= (@events_by_room[room] || []).dup
  end

  def rooms
    return [] unless @day&.rooms_with_events
    @selected_rooms || @day.rooms_with_events
  end

  def select_rooms(selected)
    return [] unless @day&.rooms_with_events
    @selected_rooms = @day.rooms_with_events & selected
  end

  def room_slice_names
    return [] unless @day&.rooms_with_events
    @day.rooms_with_events.each_slice(7).map do |s|
      s.map(&:name)
    end
  end

  def speakers
    @speakers ||= Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).order(:public_name, :first_name, :last_name)
  end

  def for_speaker(id)
    @speaker = Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).find(id)
    self
  end

  # Provide structured data for desktop table view
  def schedule_grid_data
    return [] unless @day&.rooms_with_events

    @schedule_grid_data ||= build_schedule_grid_data
  end

  # Provide structured data for tablet timeline view
  def timeline_data
    return [] unless @day&.rooms_with_events

    @timeline_data ||= build_timeline_data
  end

  # Provide structured data for mobile list view
  def mobile_schedule_data
    return [] unless @day&.rooms_with_events

    @mobile_schedule_data ||= build_mobile_schedule_data
  end

  private

  def build_events_by_room
    @events_by_room = {}
    return @events_by_room unless @day&.rooms_with_events

    @day.rooms_with_events.each do |room|
      @events_by_room[room] = room.events.confirmed.no_conflicts.is_public.scheduled_on(@day).order(:start_time).to_a
    end
    @events_by_room
  end

  # Build data structure for desktop table grid view
  def build_schedule_grid_data
    timeslots = []

    # Create independent working copies for this method
    working_events = {}
    build_events_by_room unless @events_by_room
    @day.rooms_with_events.each do |room|
      working_events[room] = (@events_by_room[room] || []).dup
    end

    time = @day.start_date
    slot = 0

    while time < @day.end_date
      timeslot_data = {
        time: time,
        slot: slot,
        show_time: (slot % @conference.default_timeslots == 0),
        rooms: {}
      }

      room_slices.each do |rooms|
        rooms.each do |room|
          events_for_room = working_events[room] || []

          if events_for_room.any? && events_for_room.first.start_time == time
            event = events_for_room.shift
            timeslot_data[:rooms][room] = {
              type: :event,
              event: event,
              rowspan: event.time_slots,
              height: event.time_slots * 40
            }
          else
            timeslot_data[:rooms][room] = { type: :empty }
          end
        end
      end

      timeslots << timeslot_data
      time = time.since(@conference.timeslot_duration.minutes)
      slot += 1
    end

    timeslots
  end

  # Build data structure for tablet timeline view
  def build_timeline_data
    events_by_time = {}

    # Create independent working copies for this method
    working_events = {}
    build_events_by_room unless @events_by_room
    @day.rooms_with_events.each do |room|
      working_events[room] = (@events_by_room[room] || []).dup
    end

    time = @day.start_date
    while time < @day.end_date
      room_slices.first.each do |room|
        events_for_room = working_events[room] || []

        if events_for_room.any? && events_for_room.first.start_time == time
          event = events_for_room.shift
          events_by_time[time] ||= []
          events_by_time[time] << { event: event, room: room }
        end
      end

      time = time.since(@conference.timeslot_duration.minutes)
    end

    # Convert to sorted array of time blocks
    events_by_time.map do |time, event_rooms|
      {
        time: time,
        event_rooms: event_rooms
      }
    end.sort_by { |block| block[:time] }
  end

  # Build data structure for mobile list view
  def build_mobile_schedule_data
    # Create independent copies for this method (though mobile doesn't use .shift)
    build_events_by_room unless @events_by_room

    room_slices.map do |rooms|
      rooms.map do |room|
        {
          room: room,
          events: (@events_by_room[room] || []).dup  # Always return a fresh copy
        }
      end
    end.flatten
  end
end

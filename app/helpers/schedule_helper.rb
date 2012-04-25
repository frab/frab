module ScheduleHelper

  def day_active?(index)
    "active" if params[:day].to_i == index
  end

  def landscape?
    @rooms.size > 3
  end

  # for pdf
  def number_of_rows
    ((@conference.day_end - @conference.day_start) * 60 / @conference.timeslot_duration).to_i
  end
 
  # for pdf
  def number_of_timeslots
    number_of_rows * 15.0 / @conference.timeslot_duration
  end

  # for event boxes in public schedule
  def event_coordinates(room_index, event, column_width, row_height, offset = 0)
    x = 1.5.cm - 1 + room_index * column_width
    day_end = event.start_time.change(:hour => @conference.day_end, :min => 0)
    y = ((day_end - event.start_time) / (@conference.timeslot_duration * 60)) * row_height
    y += offset
    [x, y]
  end

  def each_minutes(minutes, &block)
    time = @conference.day_start*60
    while time < @conference.day_end*60
      yield time
      time += minutes
    end
  end

  def each_15_minutes(&block)
    each_minutes(15, &block)
  end

  def minutes_to_time_str(minutes)
    "#{minutes/60}:" + "%02d" % (minutes%60)
  end

end

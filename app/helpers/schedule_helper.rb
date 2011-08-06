module ScheduleHelper

  def day_active?(index)
    classes = nil
    classes = "active" if params[:day].to_i == index
    classes = "#{classes} first" if index == 0
  end

  def landscape?
    @rooms.size > 3
  end

  def number_of_rows
    ((@conference.day_end - @conference.day_start) / 900).to_i
  end
 
  def number_of_timeslots
    number_of_rows * 15.0 / @conference.timeslot_duration
  end

  def event_coordinates(room_index, event, column_width, row_height, offset = 0)
    x = 1.5.cm - 1 + room_index * column_width
    day_end = event.start_time.change(:hour => @conference.day_end.hour, :min => @conference.day_end.min)
    y = ((day_end - event.start_time) / (@conference.timeslot_duration * 60)) * row_height
    y += offset
    [x, y]
  end

  def each_minutes(minutes, &block)
    time = @conference.day_start
    while (time < @conference.day_end)
      yield time
      time = time.since(minutes.minutes)
    end
  end

  def each_15_minutes(&block)
    each_minutes(15, &block)
  end

end

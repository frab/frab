module ScheduleHelper

  def day_active?(index)
    classes = nil
    classes = "active" if params[:day].to_i == index
    classes = "#{classes} first" if index == 0
  end

  def landscape?
    @rooms.size > 3
  end

  def number_of_timeslots
    ((@conference.day_end - @conference.day_start) / (@conference.timeslot_duration * 60)).to_i + 1
  end

  def number_of_rows
    ((@conference.day_end - @conference.day_start) / 900).to_i + 1
  end
  
  def event_coordinates(room_index, event, column_width, row_height)
    x = 1.5.cm + room_index * column_width
    day_end = event.start_time.change(:hour => @conference.day_end.hour, :min => @conference.day_end.min)
    y = ((day_end - event.start_time) / (@conference.timeslot_duration * 60) + 1) * row_height
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

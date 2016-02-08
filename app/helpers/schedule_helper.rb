module ScheduleHelper
  def day_active?(index)
    'active' if params[:day].to_i == index
  end

  def landscape?
    @rooms.size > 3
  end

  # for pdf
  def number_of_timeslots
    timeslots_between(@day.start_date, @day.end_date)
  end

  # for pdf: event boxes in public schedule
  def event_coordinates(room_index, event, column_width, row_height, offset = 0)
    x = 1.5.cm - 1 + room_index * column_width
    y = (timeslots_between(event.start_time, @day.end_date) - 1) * row_height
    y += offset
    [x, y]
  end

  def each_minutes(minutes)
    time = @day.start_date
    while time < @day.end_date
      yield time
      time = time.since(minutes.minutes)
    end
  end

  def each_15_minutes(&block)
    each_minutes(15, &block)
  end

  def timeslots_between(start_date, end_date)
    ((end_date - start_date) / 60 / @conference.timeslot_duration).to_i + 1
  end
end

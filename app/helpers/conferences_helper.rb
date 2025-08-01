module ConferencesHelper
  def active_tab(current, active)
    return 'active' if current == active
    ''
  end

  def timeslot_durations(conference)
    result = []
    durations = [1, 5, 10, 15, 20, 30, 45, 60, 90, 120]
    if conference.timeslot_duration and conference.events.count > 0
      durations.reject! do |duration|
        duration > conference.timeslot_duration or (conference.timeslot_duration % duration) != 0
      end
    end
    durations.each do |duration|
      result << [duration_to_time(duration), duration]
    end
    result
  end

  def flash_alert(t)
    { "notice" => "success", "alert" => "danger", "errors" => "danger" }.fetch(t, t)
  end
end

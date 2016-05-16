module Public::ScheduleHelper
  require 'scanf'

  def each_timeslot(&block)
    each_minutes(@conference.timeslot_duration, &block)
  end

  def color_dark?(color)
    parts = color.scanf('%02x%02x%02x')
    return parts.sum < 384 if parts.length == 3

    parts = color.scanf('%01x%01x%01x')
    return parts.sum < 24 if parts.length == 3

    false
  end

  def track_class(event)
    if event.track
      "track-#{event.track.name.parameterize}"
    else
      'track-default'
    end
  end

  def different_track_colors?
    colors = @conference.tracks.map(&:color)
    colors.uniq.size > 1
  end

  def selected(regex)
    'selected' if request.path =~ regex
  end

  def day_selected(index)
    'selected' if request.path.ends_with?(index.to_s)
  end
end

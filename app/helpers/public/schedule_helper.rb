module Public::ScheduleHelper
  require 'scanf'

  def public_program_event_url(event)
    if event.conference.program_export_base_url.present?
      File.join event.conference.program_export_base_url, "events/#{event.id}.html"
    else
      url_for(public_event_url(id: event.id))
    end
  end

  def schedule_title
    t('public.schedule.title', title: @conference.title)
  end

  def day_title
    t('.schedule_for_day', index: @day_index, label: l(@view_model.day.date)) if @conference.days.length > 1
    t('.schedule', label: l(@view_model.day.date))
  end

  def event_title
    title_fragments = []
    title_fragments << event_title_with_type(@view_model.event)
    title_fragments << @view_model.event.start_time.strftime('%A') if @conference.days.length > 1
    title_fragments.join ' | '
  end

  def event_title_with_type(event)
    event_type = if event.event_type.present?
                   t("options.#{event.event_type}")
                 else
                   t('options.other')
                 end
    "#{event_type.capitalize}: #{event.title}"
  end

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
    colors = @conference.tracks_including_subs.map(&:color)
    colors.uniq.size > 1
  end

  def selected(regex)
    'selected' if request.path.match?(regex)
  end

  def day_selected(index)
    'selected' if request.path.ends_with?(index.to_s)
  end
end

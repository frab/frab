module EventsHelper
  def fix_http_proto(url)
    if url.start_with?('https') or url.start_with?('http') or url.start_with?('ftp')
      url
    else
      "http://#{url}"
    end
  end

  def event_start_time
    return t(:date_not_set) unless @event.start_time
    I18n.l(@event.start_time, format: :pretty_datetime)
  end

  def timeslots
    slots = []
    (@conference.max_timeslots + 1).times do |i|
      slots << [format_time_slots(i), i]
    end
    slots
  end

  def format_time_slots(number_of_time_slots)
    duration_in_minutes = number_of_time_slots * @conference.timeslot_duration
    duration_to_time(duration_in_minutes)
  end

  FilterData = Struct.new(:type, :attribute_name, :qname, :filter_name_i18n, :filter_name, :i18n_scope)

  def filters_data
    [ FilterData[:text,
                 'tracks.name',
                 'track_name',
                 'activerecord.attributes.event.track'],
      FilterData[:text,
                 :event_type,
                 'event_type',
                 'activerecord.attributes.event.event_type',
                 nil,
                 'options'],
      FilterData[:text,
                 :state,
                 'event_state',
                 'activerecord.attributes.event.state',
                 nil,
                 'conferences_module'] ].freeze
  end

  def show_filters_pane?
    filters_data.each do |f|
      return true if params[f.qname].present?
    end
    false
  end
end

module EventsHelper
  def fix_http_proto(url)
    if url.start_with?('https') or url.start_with?('http') or url.start_with?('ftp')
      url
    else
      "http://#{url}"
    end
  end

  def showing_my_events?
     params[:events]=='my'
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
  
  def timeslots_for_cfp
    @conference.allowed_event_timeslots.map{|slots| [format_time_slots(slots), slots]}
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
                 'conferences_module'],
      FilterData[:range,
                  :average_rating,
                  'average_rating',
                  'activerecord.attributes.event.average_rating'],
       FilterData[:range,
                  :event_ratings_count,
                  'event_ratings_count',
                  'activerecord.attributes.event.event_ratings_count'] ].freeze +
       @conference.review_metrics.map{ |rm| FilterData[:range,
                                                      "#{rm.safe_name}.score",
                                                      rm.safe_name,
                                                      nil,
                                                      rm.name] }
  end

  def show_filters_pane?
    filters_data.each do |f|
      return true if params[f.qname]
    end
    false
  end
  
  def localized_filter_options(c, i18n_scope)
    c = split_filter_string(c) if c.is_a? String
    options = (c - ['',nil]).map{|v| [ if i18n_scope 
                                         t(v, scope: i18n_scope, default: v)
                                       else  
                                         v
                                       end,
                                       v]    }.sort
    if c.include? '' or c.include? nil
      options.push [ t('blank_indication'), '' ]
    end
    options
  end
  
  def split_filter_string(s)
    return [''] if s==''
    s.split('|', -1)
  end

  def filter_link(qname, text='')
    link_to text, '#',
            class: [ 'show_filter_modal', ('filter_icon' unless text.present?), params[qname].present? ] ,
            data: { url: filter_modal_events_url(request.query_parameters.merge(which_filter: qname)) }
  end
  
  def get_op_and_val(str)
    /^(?<op>[≤≥=]?)(?<val>.*)$/ =~ str
    return op, val
  end
end

json.array! @events do |e|
  json.event_id e.id
  json.extract! e, :track_id, :room_id, :start_time, :title, :abstract, :language
  json.track_name e.track.try(:name)
  json.room_name e.room.try(:name)
  json.duration e.duration_in_minutes
  json.speaker_names e.speakers.map(&:public_name).join(', ')
  json.event_url event_url(e)
  json.speakers e.speakers do |speaker|
    json.public_name speaker.public_name
    json.abstract speaker.abstract
    json.description speaker.description
    json.availabilities speaker.availabilities_in(event.conference) do |availibility|
      json.extract! availibility, :start_date, :end_date, :day_id
    end
  end
end

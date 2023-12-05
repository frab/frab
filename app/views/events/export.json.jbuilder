json.array! @events do |e|
  json.event_id e.id
  json.event_url event_url(e)
  json.public_event_url public_program_event_url(e)
  json.extract! e, :guid, :id, :track_id, :room_id, :start_time, :title, :subtitle, :description, :abstract, :language
  json.track_name e.track.try(:name)
  json.room_name e.room.try(:name)
  json.duration e.duration_in_minutes
  json.speaker_names e.speakers.map(&:public_name).join(', ')
  json.type e.event_type
  json.speakers e.speakers do |speaker|
    json.id speaker.id
    json.public_name speaker.public_name
    json.abstract speaker.abstract
    json.description speaker.description
    json.availabilities speaker.availabilities_in(e.conference) do |availibility|
      json.extract! availibility, :start_date, :end_date, :day_id
    end
  end
  json.event_classifiers e.event_classifiers.map(&:as_array).to_h
end

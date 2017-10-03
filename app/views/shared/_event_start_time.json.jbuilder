if event.start_time and event.room
  json.start_time event.start_time
  json.end_time event.end_time
  json.room do
    json.name event.room.name
    json.id event.room.id
  end
end

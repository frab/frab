json.acronym conference.acronym
json.title conference.title
if conference.days.length > 0
  json.start conference.first_day.start_date.strftime('%Y-%m-%d')
  json.end conference.last_day.end_date.strftime('%Y-%m-%d')
end
json.daysCount conference.days.length
json.timeslot_duration duration_to_time(conference.timeslot_duration)
index = 0
json.days conference.days do |day|
  json.index index
  index += 1
  json.date day.start_date.strftime('%Y-%m-%d')
  json.day_start day.start_date.iso8601
  json.day_end day.end_date.iso8601
  json.rooms do
    conference.rooms.is_public.each do |room|
      json.set! room.name, room.events.is_public.accepted.scheduled_on(day).order(:start_time) do |event|
        json.id event.id
        json.guid event.guid
      end
    end
  end
end

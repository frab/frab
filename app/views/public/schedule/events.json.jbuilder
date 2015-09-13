json.conference_events do
  json.version @conference.schedule_version if @conference.schedule_version.present?
  json.events @events do |event|
    json.id event.id
    json.guid event.guid
    json.title event.title
    json.logo event.logo_path
    json.type event.event_type
    json.do_not_record event.do_not_record
    if event.start_time and event.room
      json.start_time event.start_time
      json.end_time event.end_time
      json.room do
        json.name event.room.name
        json.id event.room.id
      end
    end
    json.abstract event.abstract
    json.speakers event.speakers do |person|
      json.id person.id
      json.image person.avatar_path
      json.full_public_name person.public_name
      json.abstract person.abstract
      json.description person.description
      json.links person.links do |link|
        json.url url_for(link.url)
        json.title link.title
      end
    end
  end
end

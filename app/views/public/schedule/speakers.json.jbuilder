json.schedule_speakers do
  json.version @conference.schedule_version if @conference.schedule_version.present?
  json.speakers @speakers do |person|
    json.id person.id
    json.image person.avatar_path
    json.full_public_name person.public_name
    json.abstract person.abstract
    json.description person.description
    json.links person.links do |link|
      json.url url_for(link.url)
      json.title link.title
    end
    json.events person.public_and_accepted_events_as_speaker_in(@conference) do |event|
      json.id event.id
      json.guid event.guid
      json.title event.title
      json.logo event.logo_path
      json.type event.event_type
    end
  end
end

json.schedule_speakers do
  json.version @conference.schedule_version if @conference.schedule_version.present?
  json.speakers @speakers do |person|
    json.partial! 'shared/person', person: person
    json.events person.public_and_accepted_events_as_speaker_in(@conference) do |event|
      json.id event.id
      json.guid event.guid
      json.title event.title
      json.logo event.logo_path
      json.type event.event_type
    end
  end
end

json.id event.id
json.guid event.guid
json.title event.title
json.language event.language
json.subtitle event.subtitle
json.description event.description
# duration_in_minutes returns an ActiveSupport::Duration; .to_i emits it as
# seconds. Kept in seconds for backwards compatibility with API consumers.
json.duration event.duration_in_minutes.to_i
json.time_slots event.time_slots
json.logo event.logo_path(:original)
json.type event.event_type
json.do_not_record event.do_not_record
json.track event.track&.name
json.abstract event.abstract
json.speakers event.speakers do |person|
  json.partial! 'shared/person', person: person
end

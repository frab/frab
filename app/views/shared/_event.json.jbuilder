json.id event.id
json.guid event.guid
json.title event.title
json.subtitle event.subtitle
json.description event.description
json.duration event.duration_in_minutes
json.logo event.logo_path(:original)
json.type event.event_type
json.do_not_record event.do_not_record
json.track event.track&.name
json.abstract event.abstract
json.speakers event.speakers do |person|
  json.partial! 'shared/person', person: person
end
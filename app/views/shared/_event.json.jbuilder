json.id event.id
json.guid event.guid
json.title event.title
json.subtitle event.subtitle
json.description event.description
json.logo event.logo_path(:original)
json.type event.event_type
json.do_not_record event.do_not_record
json.track event.track&.name
json.abstract event.abstract
json.speakers event.speakers do |person|
  json.id person.id
  json.image person.avatar_path(:original)
  json.full_public_name person.public_name
  json.abstract person.abstract
  json.description person.description
  json.links person.links do |link|
    json.url url_for(link.url)
    json.title link.title
  end
end

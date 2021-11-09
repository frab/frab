json.guid person.guid
json.id person.id
json.image person.avatar_path(:original)
json.name person.public_name
json.public_name person.public_name
if person.email_public?
  json.email person.email
end
json.abstract person.abstract
json.description person.description
json.links person.links do |link|
  json.url url_for(link.url)
  json.title link.title
end

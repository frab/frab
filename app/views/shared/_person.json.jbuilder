json.id person.id
json.image person.avatar_path
json.full_public_name person.public_name
json.abstract person.abstract
json.description person.description
json.links person.links do |link|
  json.url url_for(link.url)
  json.title link.title
end

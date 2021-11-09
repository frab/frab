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
if policy(Conference).manage?
  json.full_name person.full_name
  json.email person.email
  json.contacts do
    json.array!(person.phone_numbers) do |phone_number|
      json.type phone_number.phone_type
      json.identifier phone_number.phone_number
    end
    json.array!(person.im_accounts) do |im_account|
      json.type im_account.im_type
      json.identifier im_account.im_address
    end
  end
end
json.set! :'@context' do
  json.name 'http://xmlns.com/foaf/0.1/name'
  json.homepage do
    json.set! :'@id', 'http://xmlns.com/foaf/0.1/workplaceHomepage'
    json.set! :'@type', '@id'
  end
  json.Person "http://xmlns.com/foaf/0.1/Person"
end

json.set! :'@id', conference&.program_export_base_url || 'https://github.com/frab/frab'
json.set! :'@type', 'Person'
json.extract! person,
  :first_name, :last_name, :public_name,
  :email, :email_public, :include_in_mailings,
  :gender,
  :abstract, :description
json.set! :avatar, Base64.encode64(Paperclip.io_adapters.for(person.avatar).read) if person.avatar.present?

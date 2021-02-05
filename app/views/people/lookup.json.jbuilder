json.msg @msg
json.too_many @too_many 
json.people @people do |person|
  json.id person.id
  json.text person.full_name_annotated
end

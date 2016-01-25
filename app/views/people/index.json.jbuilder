json.people @people do |json, person|
  json.partial! 'shared/person', person: person
end

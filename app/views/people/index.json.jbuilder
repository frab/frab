json.people @people do |person|
  json.partial! 'shared/person', person: person
end

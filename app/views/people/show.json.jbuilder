json.partial! 'shared/person', person: @person
json.origin ENV.fetch('FRAB_HOST')

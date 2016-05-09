json.conferences @conferences do |json, conference|
  json.partial! 'shared/event', conference: conference
end

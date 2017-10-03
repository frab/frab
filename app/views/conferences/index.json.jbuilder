json.conferences conferences do |conference|
  json.partial! 'shared/conference', conference: conference
end

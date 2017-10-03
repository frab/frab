json.events @events do |event|
  json.partial! 'shared/event', event: event
  json.partial! 'shared/event_crew', event: event
  if policy(event.conference).orga?
    json.partial! 'shared/event_orga', event: event
  end
end

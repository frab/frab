json.conference_events do
  json.version @conference.schedule_version if @conference.schedule_version.present?
  json.events @events do |event|
    json.partial! 'shared/event', event: event
  end
end

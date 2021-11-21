json.track event.track.try(:name)
json.event_classifiers event.event_classifiers.map(&:as_array).to_h
json.language event.language
json.recording_license event.recording_license
json.links event.links do |link|
  json.url url_for(link.url)
  json.title link.title
end
json.attachments event.event_attachments.is_public.each do |attachment|
  json.url attachment.attachment.url
  json.title attachment.link_title
end
json.speakers event.speakers do |person|
  json.partial! 'shared/person', person: person
  json.state person.role_state(event.conference)
  json.availabilities person.availabilities_in(event.conference).each do |a|
    json.start a.start_date.iso8601
    json.end a.end_date.iso8601
  end
  json.url person_url(person)
  json.public_url url_for(public_event_url(event))
end
if event.remote_ticket?
  json.ticket do
    json.id event.ticket.remote_ticket_id
    unless event.conference.ticket_server.nil?
      json.url get_ticket_view_url(event.ticket.remote_ticket_id)
    end
  end
end
# techrider, submission_notes?
json.origin ENV.fetch('FRAB_HOST')
json.url event_url(event)
json.public_url public_event_url(event)

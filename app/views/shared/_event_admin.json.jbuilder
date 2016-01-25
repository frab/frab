json.subtitle event.subtitle
json.track event.track.try(:name)
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

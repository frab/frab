json.speaker_ids event.speakers.map(&:id)
json.state event.state
json.partial! 'shared/event_start_time', event: event

json.notification do
  json.extract! @notification, :accept_subject, :accept_body, :reject_subject, :reject_body, :schedule_subject, :schedule_body
end

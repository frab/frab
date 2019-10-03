class MailTemplate < ApplicationRecord
  belongs_to :conference
  validates :name, presence: true
  validates :subject, presence: true
  validates :content, presence: true

  def message_text_for_event_person(event_person)
    { subject: event_person.substitute_variables(subject),
      body: event_person.substitute_variables(content) }
  end

  def send_sync(filter)
    job = SendBulkMailJob.new(self, filter)
    job.perform
  end

  def send_async(filter)
    job = SendBulkMailJob.new(self, filter)
    job.async.perform
  end
end

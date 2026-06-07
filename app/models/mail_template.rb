class MailTemplate < ApplicationRecord
  belongs_to :conference

  default_scope { order(name: :asc) }

  validates :name, presence: true
  validates :subject, presence: true
  validates :content, presence: true

  def message_text_for_event_person(event_person)
    { subject: event_person.substitute_variables(subject),
      body: event_person.substitute_variables(content) }
  end

  def send_sync(filter)
    job = SendBulkMailJob.new
    job.perform(self, filter)
  end

  def send_async(filter)
    job = SendBulkMailJob.new
    job.async.perform(self, filter)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[conference_id content created_at id name subject updated_at]
  end
end

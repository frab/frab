class MailTemplate < ApplicationRecord
  belongs_to :conference
  validates :name, presence: true
  validates :subject, presence: true
  validates :content, presence: true

  def content_for(user)
    content
      .gsub('#first_name',  user.first_name)
      .gsub('#last_name',   user.last_name)
      .gsub('#public_name', user.public_name)
  end

  def send_sync(filter)
    job = SendBulkMailJob.new
    job.perform self, filter
  end

  def send_async(filter)
    job = SendBulkMailJob.new
    job.async.perform self, filter
  end
end

class AddScheduleSubjectAndScheduleBodyToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :schedule_subject, :string, limit: 255
    add_column :notifications, :schedule_body, :text
  end
end

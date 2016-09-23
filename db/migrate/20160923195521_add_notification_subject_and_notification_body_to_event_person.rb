class AddNotificationSubjectAndNotificationBodyToEventPerson < ActiveRecord::Migration
  def change
    add_column :event_people, :notification_subject, :string, limit: 255
    add_column :event_people, :notification_body, :text
  end
end

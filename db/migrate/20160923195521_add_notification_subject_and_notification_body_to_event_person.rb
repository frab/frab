class AddNotificationSubjectAndNotificationBodyToEventPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :event_people, :notification_subject, :string, limit: 255
    add_column :event_people, :notification_body, :text
  end
end

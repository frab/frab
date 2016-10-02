class AddBulkNotificationEnabledToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :bulk_notification_enabled, :boolean, default: false, null: false
  end
end

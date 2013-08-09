class FeedbackEnabledBoolean < ActiveRecord::Migration
  def up
    change_column :conferences, :feedback_enabled, :boolean, default: false
  end

  def down
    change_column :conferences, :feedback_enabled, :integer
  end
end

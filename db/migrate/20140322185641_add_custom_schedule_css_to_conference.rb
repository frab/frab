class AddCustomScheduleCssToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :schedule_custom_css, :text, limit: 2.megabytes
  end
end

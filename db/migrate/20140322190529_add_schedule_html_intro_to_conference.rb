class AddScheduleHtmlIntroToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :schedule_html_intro, :text, limit: 2.megabytes
  end
end

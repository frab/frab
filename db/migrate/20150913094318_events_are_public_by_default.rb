class EventsArePublicByDefault < ActiveRecord::Migration[4.2]
  def change
    change_column :events, :public, :boolean, default: true
  end
end

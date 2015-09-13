class EventsArePublicByDefault < ActiveRecord::Migration
  def change
    change_column :events, :public, :boolean, default: true
  end
end

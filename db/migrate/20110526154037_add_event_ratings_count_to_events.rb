class AddEventRatingsCountToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :event_ratings_count, :integer, default: 0
    Event.reset_column_information
    Event.includes(:event_ratings).all.each do |event|
      Event.update_counters event.id, event_ratings_count: event.event_ratings.size unless event.event_ratings.empty?
    end
  end

  def self.down
    remove_column :events, :event_ratings_count
  end
end

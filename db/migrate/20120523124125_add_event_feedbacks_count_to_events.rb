class AddEventFeedbacksCountToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :event_feedbacks_count, :integer, default: 0
    Event.reset_column_information
    Event.includes(:event_feedbacks).all.each do |event|
      Event.update_counters event.id, event_feedbacks_count: event.event_feedbacks.size unless event.event_feedbacks.empty?
    end
  end

  def self.down
    remove_column :events, :event_feedbacks_count
  end
end

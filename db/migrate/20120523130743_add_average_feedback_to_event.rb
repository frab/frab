class AddAverageFeedbackToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :average_feedback, :float
    Event.joins(:event_feedbacks).readonly(false).all.each {|e| e.recalculate_average_feedback!}
  end

  def self.down
    remove_column :events, :average_feedback
  end
end

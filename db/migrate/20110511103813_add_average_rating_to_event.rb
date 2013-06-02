class AddAverageRatingToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :average_rating, :float
    # Undefined method? Event.disable_auditing
    Event.joins(:event_ratings).readonly(false).all.each {|e| e.recalculate_average_rating!}
  end

  def self.down
    remove_column :events, :average_rating
  end
end

class AddAverageRatingToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :average_rating, :float
  end

  def self.down
    remove_column :events, :average_rating
  end
end

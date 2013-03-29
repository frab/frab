class AddColorToTrack < ActiveRecord::Migration
  def self.up
    add_column :tracks, :color, :string, default: "fefd7f"
  end

  def self.down
    remove_column :tracks, :color
  end
end

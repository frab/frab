class ConvertEventStates < ActiveRecord::Migration
  def self.up
    remove_column :events, :progress
    change_column :events, :state, :string, :default => "new", :null => false
  end

  def self.down
    add_column :events, :progress, :string, :default => "new", :null => false
    change_column :events, :state, :string, :default => "undecided", :null => false
  end
end

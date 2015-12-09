class AddTechRiderToEvent < ActiveRecord::Migration
  def change
    add_column :events, :tech_rider, :text
  end
end

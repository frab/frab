class AddTechRiderToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :tech_rider, :text
  end
end

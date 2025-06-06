class AddPositionToEventPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :event_people, :position, :integer
  end
end

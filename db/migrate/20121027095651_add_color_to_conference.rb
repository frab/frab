class AddColorToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :color, :string
  end
end

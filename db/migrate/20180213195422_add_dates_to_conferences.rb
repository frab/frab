class AddDatesToConferences < ActiveRecord::Migration[5.1]
  def change
    add_column :conferences, :start_date, :datetime
    add_column :conferences, :end_date, :datetime
  end
end

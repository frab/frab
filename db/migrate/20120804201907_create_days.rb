class CreateDays < ActiveRecord::Migration
  def up
    create_table :days do |t|
      t.integer  :conference_id
      t.datetime :start_date
      t.datetime :end_date
    end
  end
  def self.down
    drop_table :days
  end

end

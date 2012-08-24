class CreatePhoneNumbers < ActiveRecord::Migration
  def self.up
    create_table :phone_numbers do |t|
      t.integer :person_id
      t.string :phone_type
      t.string :phone_number

      t.timestamps
    end
  end

  def self.down
    drop_table :phone_numbers
  end
end

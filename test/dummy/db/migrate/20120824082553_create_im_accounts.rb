class CreateImAccounts < ActiveRecord::Migration
  def self.up
    create_table :im_accounts do |t|
      t.integer :person_id
      t.string :im_type
      t.string :im_address

      t.timestamps
    end
  end

  def self.down
    drop_table :im_accounts
  end
end

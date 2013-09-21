class CreateConferenceUsers < ActiveRecord::Migration
  def change
    create_table :conference_users do |t|
      t.string :role
      t.references :user
      t.references :conference

      t.timestamps
    end
    add_index :conference_users, :user_id
    add_index :conference_users, :conference_id
  end
end

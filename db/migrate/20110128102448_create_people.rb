class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :public_name
      t.string :email, null: false
      t.boolean :email_public
      t.string :gender
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.text :abstract
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end

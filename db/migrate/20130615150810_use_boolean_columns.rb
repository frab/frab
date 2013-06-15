class UseBooleanColumns < ActiveRecord::Migration
  def up
    change_column :events, :public, :boolean, default: false
    change_column :people, :email_public, :boolean, default: true
    change_column :rooms, :public, :boolean, default: true
  end

  def down
    change_column :events, :public, :integer
    change_column :people, :email_public, :integer
    change_column :rooms, :public, :integer
  end
end

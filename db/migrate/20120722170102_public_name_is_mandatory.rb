class PublicNameIsMandatory < ActiveRecord::Migration
  def up
    change_column :people, :first_name, :string, default: "", null: true
    change_column :people, :last_name, :string, default: "", null: true
    change_column :people, :public_name, :string, null: false
  end

  def down
    change_column :people, :first_name, :string, null: false
    change_column :people, :last_name, :string, null: false
    change_column :people, :public_name, :string
  end
end

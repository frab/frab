class AddOrganizationToEvents < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :organization, :string, null: false, default: ""
  end

  def down
    remove_column :events, :organization
  end
end

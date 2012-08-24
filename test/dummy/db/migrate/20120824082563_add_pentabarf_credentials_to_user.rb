class AddPentabarfCredentialsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :pentabarf_salt, :string
    add_column :users, :pentabarf_password, :string
  end

  def self.down
    remove_column :users, :pentabarf_salt
    remove_column :users, :pentabarf_password
  end
end

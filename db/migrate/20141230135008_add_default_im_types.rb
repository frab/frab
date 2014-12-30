class AddDefaultImTypes < ActiveRecord::Migration
  def up
  	add_column :conferences, :default_im_types, :string
  end

  def down
  	remove_column :conferences, :default_im_types
  end
end

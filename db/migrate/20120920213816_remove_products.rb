class RemoveProducts < ActiveRecord::Migration
  def up
    drop_table :ordered_products
    drop_table :product_types
  end

  def down
  end
end

class CreateProducts < ActiveRecord::Migration

  def up
    create_table "ordered_products", :force => true do |t|
      t.integer  "attendee_id"
      t.integer  "product_type_id"
      t.integer  "amount"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "product_types", :force => true do |t|
      t.string   "type"
      t.integer  "attendee_registration_id"
      t.string   "name"
      t.decimal  "price",                    :precision => 7, :scale => 2
      t.decimal  "vat",                      :precision => 4, :scale => 2
      t.integer  "includes_vat"
      t.date     "available_until"
      t.integer  "amount_available"
      t.integer  "needs_invoice_address"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "currency"
    end
  end

  def down
    drop_table :ordered_products
    drop_table :product_types
  end

end

class AddDecimalPlaceToExpenses < ActiveRecord::Migration[4.2]
  def change
    change_column :expenses, :value, :decimal, precision: 7, scale: 2
  end
end

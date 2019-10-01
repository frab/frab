class FixDecimalPlaceInExpenses < ActiveRecord::Migration[5.2]
  def change
    change_column :expenses, :value, :decimal, precision: 9, scale: 4
  end
end


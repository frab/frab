class FixDecimalPlaceInExpenses < ActiveRecord::Migration[5.2]
  def self.up
    change_column :expenses, :value, :decimal, precision: 9, scale: 4
  end
  def self.down
  end
end


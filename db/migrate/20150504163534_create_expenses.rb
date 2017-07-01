class CreateExpenses < ActiveRecord::Migration[4.2]
  def change
    create_table :expenses do |t|
      t.string :name
      t.decimal :value
      t.boolean :reimbursed
      t.references :person
      t.references :conference

      t.timestamps
    end
    add_index :expenses, :person_id
    add_index :expenses, :conference_id
  end
end

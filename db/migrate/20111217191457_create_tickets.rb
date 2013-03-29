class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :event_id, null: false
      t.string :remote_ticket_id

      t.timestamps
    end
  end
end

class CreateTicketServers < ActiveRecord::Migration
  def change
    create_table :ticket_servers do |t|
      t.integer :conference_id, null: false
      t.string :url
      t.string :user
      t.string :password
      #t.column :type, :string

      t.timestamps
    end
  end
end

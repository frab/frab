class ConferenceTicketType < ActiveRecord::Migration
  def up
    add_column :conferences, :ticket_type, :string
  end

  def down
    remove_column :conferences, :ticket_type
  end
end

class MakeTicketAssociationPolymorphic < ActiveRecord::Migration
  def up
    rename_column :tickets, :event_id, :object_id
    add_column :tickets, :object_type, :string

    # turn all existing ticket associations to type 'Event'
    Ticket.update_all(object_type: "Event")
  end

  def down
    rename_column :tickets, :object_id, :event_id
    remove_column :tickets, :object_type
  end
end

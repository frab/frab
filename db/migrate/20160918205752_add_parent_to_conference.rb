class AddParentToConference < ActiveRecord::Migration[4.2]
  def change
    add_reference :conferences, :parent, index: true
  end
end

class AddParentToConference < ActiveRecord::Migration
  def change
    add_reference :conferences, :parent, index: true
  end
end

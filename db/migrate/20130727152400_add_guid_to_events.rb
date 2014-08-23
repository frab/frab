class AddGuidToEvents < ActiveRecord::Migration
  def up
    add_column :events, :guid, :string
    Event.reset_column_information
    Event.all.each { |e|
      e.guid = SecureRandom.uuid
      e.save(validate: false)
    }
  end

  def down
    remove_column :events, :guid
  end
end

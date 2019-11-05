class AddAllowedEventTypesToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :allowed_event_types, :string, default: Event::TYPES.join(';')
  end
end

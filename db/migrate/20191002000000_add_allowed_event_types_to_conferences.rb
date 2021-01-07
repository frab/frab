class AddAllowedEventTypesToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :allowed_event_types, :string,
      default: %w(lecture workshop podium lightning_talk meeting film concert djset performance other).join(';')
  end
end

class EventTitleNullable < ActiveRecord::Migration[5.2]
  def up
    change_column :events, :title, :string, null: true
  end

  def down
    change_column :events, :title, :string, null: false
  end
end

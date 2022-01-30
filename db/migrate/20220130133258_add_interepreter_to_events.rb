class AddInterepreterToEvents < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :interpreter, :string, limit: 255
  end

  def down
    remove_column :events, :interpreter
  end
end

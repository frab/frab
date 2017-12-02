class AddInviteTokenToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :invite_token, :string
    add_index :events, :invite_token, unique: true
  end
end

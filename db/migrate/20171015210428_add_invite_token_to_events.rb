class AddInviteTokenToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :invite_token, :string
  end
end

class AddFeedbackTokenToConferences < ActiveRecord::Migration[7.1]
  def change
    add_column :conferences, :feedback_token, :string
    add_index :conferences, :feedback_token, unique: true
  end
end

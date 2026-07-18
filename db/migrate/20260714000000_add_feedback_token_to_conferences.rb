class AddFeedbackTokenToConferences < ActiveRecord::Migration[7.1]
  def up
    add_column :conferences, :feedback_token, :string

    # Generate tokens for existing conferences
    Conference.reset_column_information
    Conference.find_each(&:regenerate_feedback_token!)

    add_index :conferences, :feedback_token, unique: true
  end

  def down
    remove_column :conferences, :feedback_token
  end
end

class AddFeedbackTokenToConferences < ActiveRecord::Migration[7.1]
  def up
    add_column :conferences, :feedback_token, :string

    # Generate tokens for existing conferences. update_column skips
    # validations, callbacks and paper_trail, so legacy records can't abort
    # the migration and no token ends up in the version history.
    Conference.reset_column_information
    Conference.find_each do |conference|
      conference.generate_token_for(:feedback_token)
      conference.update_column(:feedback_token, conference.feedback_token)
    end

    add_index :conferences, :feedback_token, unique: true
  end

  def down
    remove_column :conferences, :feedback_token
  end
end

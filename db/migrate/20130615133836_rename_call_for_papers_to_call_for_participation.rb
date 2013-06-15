class RenameCallForPapersToCallForParticipation < ActiveRecord::Migration
  def up
    rename_table :call_for_papers, :call_for_participations
    rename_column :users, :call_for_papers_id, :call_for_participation_id
    rename_column :notifications, :call_for_papers_id, :call_for_participation_id
  end

  def down
    rename_table :call_for_participations, :call_for_papers
    rename_column :users, :call_for_participation_id, :call_for_papers_id
    rename_column :notifications, :call_for_participation_id, :call_for_papers_id
  end
end

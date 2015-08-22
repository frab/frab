class RemoveCfpFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :call_for_papers_id
  end
end

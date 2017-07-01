class RemoveCfpFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :call_for_papers_id
  end
end

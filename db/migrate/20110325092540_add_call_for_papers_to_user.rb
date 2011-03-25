class AddCallForPapersToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :call_for_papers_id, :integer
  end

  def self.down
    remove_column :users, :call_for_papers_id
  end
end

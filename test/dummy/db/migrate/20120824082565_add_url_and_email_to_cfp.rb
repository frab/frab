class AddUrlAndEmailToCfp < ActiveRecord::Migration
  def self.up
    add_column :call_for_papers, :info_url, :string
    add_column :call_for_papers, :contact_email, :string
  end

  def self.down
    remove_column :call_for_papers, :info_url
    remove_column :call_for_papers, :contact_email
  end
end

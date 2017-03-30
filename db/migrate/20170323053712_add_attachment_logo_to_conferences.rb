class AddAttachmentLogoToConferences < ActiveRecord::Migration
  def self.up
    change_table :conferences do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :conferences, :logo
  end
end

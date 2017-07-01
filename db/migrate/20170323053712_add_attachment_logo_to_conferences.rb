class AddAttachmentLogoToConferences < ActiveRecord::Migration[5.0]
  def self.up
    change_table :conferences do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :conferences, :logo
  end
end

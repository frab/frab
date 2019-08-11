class AddMaxAttachmentSizeMbToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :max_attachment_size_mb, :integer, default: 42
  end
end

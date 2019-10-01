class AddFreeFormAttachmentTitleToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :attachment_title_is_freeform, :boolean, default: true
  end
end

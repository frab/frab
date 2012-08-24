class AddProgramExportBaseUrlToConferences < ActiveRecord::Migration
  def self.up
    add_column :conferences, :program_export_base_url, :string
  end

  def self.down
    remove_column :conferences, :program_export_base_url
  end
end

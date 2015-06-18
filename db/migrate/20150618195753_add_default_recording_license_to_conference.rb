class AddDefaultRecordingLicenseToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :default_recording_license, :string, defaults: 'CC-BY-3.0-DE'
  end
end

class AddAudioLanguagesToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :audio_languages, :text
  end
end

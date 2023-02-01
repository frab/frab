class CreateEventTitleAndSubtitleAndAbstractAndDescriptionTranslationsForMobilityTableBackend < ActiveRecord::Migration[5.2]
  def up
    create_table :event_translations do |t|

      # Translated attribute(s)
      t.string :title
      t.string :subtitle
      t.text :abstract
      t.text :description

      t.string  :locale, null: false
      t.references :event, null: false, foreign_key: true, index: false

      t.timestamps null: false
    end

    add_index :event_translations, :locale, name: :index_event_translations_on_locale
    add_index :event_translations, [:event_id, :locale], name: :index_event_translations_on_event_id_and_locale, unique: true

  end

  def down
    drop_table :event_translations
  end
end

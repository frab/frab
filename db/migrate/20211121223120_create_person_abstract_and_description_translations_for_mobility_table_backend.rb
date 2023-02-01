class CreatePersonAbstractAndDescriptionTranslationsForMobilityTableBackend < ActiveRecord::Migration[5.2]
  def up
    create_table :person_translations do |t|

      # Translated attribute(s)
      t.text :abstract
      t.text :description

      t.string  :locale, null: false
      t.references :person, null: false, foreign_key: true, index: false

      t.timestamps null: false
    end

    add_index :person_translations, :locale, name: :index_person_translations_on_locale
    add_index :person_translations, [:person_id, :locale], name: :index_person_translations_on_person_id_and_locale, unique: true

  end

  def down
    drop_table :person_translations
  end
end

class CreateEventClassifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :event_classifiers do |t|
      t.integer :value, default: 0
      t.references :classifier, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

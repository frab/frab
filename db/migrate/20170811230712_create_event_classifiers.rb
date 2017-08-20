class CreateEventClassifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :event_classifiers do |t|
      t.float :value
      t.references :classifier, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

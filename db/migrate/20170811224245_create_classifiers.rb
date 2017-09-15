class CreateClassifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :classifiers do |t|
      t.string :name
      t.string :description
      t.references :conference, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

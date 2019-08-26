class CreateReviewMetrics < ActiveRecord::Migration[5.2]
  def self.up
    create_table :review_metrics do |t|
      t.string :name
      t.string :description
      t.references :conference, index: true, foreign_key: true

      t.timestamps
    end

    add_index :review_metrics, [:name, :conference_id], unique: true
  end

  def self.down
    drop_table :review_metrics
  end
end

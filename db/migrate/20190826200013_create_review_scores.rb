class CreateReviewScores < ActiveRecord::Migration[5.2]
  def change
    create_table :review_scores do |t|
      t.references :event_rating, foreign_key: true
      t.references :review_metric, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end

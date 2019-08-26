class CreateAverageReviewScores < ActiveRecord::Migration[5.2]
  def change
    create_table :average_review_scores do |t|
      t.references :event, foreign_key: true
      t.references :review_metric, foreign_key: true
      t.float :score
    end

    add_index :average_review_scores , [:event_id, :review_metric_id], unique: true
  end
end

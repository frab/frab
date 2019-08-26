class ReviewMetric < ApplicationRecord
  belongs_to :conference
  has_many :review_score, dependent: :destroy
  has_many :average_review_score, dependent: :destroy
  
  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  def to_s
    "#{model_name.human}: #{name}"
  end
  
  validates :name, presence: true, uniqueness: { scope: :conference }
end

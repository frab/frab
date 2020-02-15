class ReviewMetric < ApplicationRecord
  belongs_to :conference
  has_many :review_score, dependent: :destroy
  has_many :average_review_score, dependent: :destroy
  
  before_save :update_events_ransacker
  
  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  def to_s
    "#{model_name.human}: #{name}"
  end
  
  def safe_name
    # safe_name is used as an sql term, and also as a request parameter.
    # So we try to have it similiar to the review metric name.
    name.parameterize.gsub(%r{[^a-z0-9]}, '_').gsub(%r{^(?=[0-9])}, '_').presence || "rm#{id}"
  end
  
  def update_events_ransacker
    Event.add_ransacker(self)
  end

  validates :name, presence: true, uniqueness: { scope: :conference }
end

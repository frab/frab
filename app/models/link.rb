class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true, optional: true

  validates :title, :url, presence: true

  has_paper_trail meta: {
    associated_id: :linkable_id,
    associated_type: :linkable_type
  }

  def to_s
    "#{model_name.human}: #{title}"
  end
end

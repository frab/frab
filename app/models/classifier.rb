class Classifier < ApplicationRecord
  belongs_to :conference
  has_many :event_classifiers, dependent: :destroy
  
  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  def to_s
    "#{model_name.human}: #{name}"
  end
  
end

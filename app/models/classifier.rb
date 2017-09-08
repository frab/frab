class Classifier < ApplicationRecord
  belongs_to :conference
  has_many :event_classifiers, dependent: :destroy

end

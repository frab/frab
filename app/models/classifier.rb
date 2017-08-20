class Classifier < ActiveRecord::Base
  belongs_to :conference
  has_many :event_classifiers, dependent: :destroy

end

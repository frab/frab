class EventClassifier < ActiveRecord::Base
  belongs_to :classifier
  belongs_to :event
end

class Video < ActiveRecord::Base
  belongs_to :event
  attr_accessible :mimetype, :url
end

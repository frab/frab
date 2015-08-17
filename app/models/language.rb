class Language < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  validates_presence_of :code
end

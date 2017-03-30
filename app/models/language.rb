class Language < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  validates :code, presence: true
end

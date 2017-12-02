class Language < ApplicationRecord
  belongs_to :attachable, polymorphic: true, optional: true

  validates :code, presence: true
end

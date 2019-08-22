class ConferenceExport < ApplicationRecord
  belongs_to :conference
  has_one_attached :tarball
  validates :locale, :conference, presence: true
end

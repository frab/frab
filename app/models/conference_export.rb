class ConferenceExport < ActiveRecord::Base
  belongs_to :conference
  has_attached_file :tarball
  validates_attachment_content_type :tarball, content_type: [/gzip/]
  validates_presence_of :locale, :conference
end

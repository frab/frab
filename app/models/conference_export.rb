class ConferenceExport < ActiveRecord::Base
  belongs_to :conference
  attr_accessible :locale, :tarball
  has_attached_file :tarball
  validates_attachment_content_type :tarball, content_type: [/gzip/]
  validates_presence_of :locale, :conference

end

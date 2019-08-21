class EventAttachment < ApplicationRecord
  belongs_to :event

  has_attached_file :attachment

  validates_attachment_size :attachment, less_than: Integer(ENV['FRAB_MAX_ATTACHMENT_SIZE_MB'] || '42').megabytes
  do_not_validate_attachment_file_type :attachment

  has_paper_trail meta: { associated_id: :event_id, associated_type: 'Event' }

  scope :is_public, -> { where(public: true) }

  def link_title
    if title.present?
      title
    elsif attachment_file_name.present?
      attachment_file_name
    else
      I18n.t('activerecord.models.event_attachment')
    end
  end
end

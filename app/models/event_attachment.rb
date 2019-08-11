class EventAttachment < ApplicationRecord
  belongs_to :event

  has_attached_file :attachment

  validates_attachment_presence :attachment

  validate :filesize_ok

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
  
  def filesize_ok
    if not attachment_file_size.nil?
      if attachment_file_size > event.conference.max_attachment_size_mb.megabytes
        errors.add(:attachment, I18n.t('events_module.error_attachment_too_large',
          allowed_mb: event.conference.max_attachment_size_mb))
      end
    end
  end
end

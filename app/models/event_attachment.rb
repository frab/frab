class EventAttachment < ApplicationRecord
  belongs_to :event

  has_one_attached :attachment

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

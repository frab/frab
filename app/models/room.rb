class Room < ApplicationRecord
  belongs_to :conference
  has_many :events

  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  default_scope -> { order(:rank) }

  validates :name, presence: true

  def to_s
    "#{model_name.human}: #{name}"
  end

  def guid
    Digest::UUID.uuid_v5(Digest::UUID::URL_NAMESPACE, uri.to_s)
  end

  def uri
    URI::HTTP.build({**conference.url_options, path: "/rooms/#{self.id}"})
  end

end

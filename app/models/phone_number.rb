class PhoneNumber < ApplicationRecord
  TYPES = %w(fax mobile phone private secretary skype work dect).freeze

  belongs_to :person

  has_paper_trail meta: { associated_id: :person_id, associated_type: 'Person' }

  def to_s
    model_name.human
  end
end

class PhoneNumber < ActiveRecord::Base
  TYPES = %w(fax mobile phone private secretary skype work)

  belongs_to :person

  has_paper_trail meta: { associated_id: :person_id, associated_type: "Person" }

  def to_s
    "Phone number"
  end
end

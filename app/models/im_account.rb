class ImAccount < ActiveRecord::Base
  TYPES = %w(aim icq jabber msn yahoo skype)

  belongs_to :person

  has_paper_trail meta: { associated_id: :person_id, associated_type: 'Person' }

  def to_s
    model_name.human
  end
end

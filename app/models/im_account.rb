class ImAccount < ActiveRecord::Base

  TYPES = %w(aim icq jabber msn yahoo)

  belongs_to :person

  acts_as_audited :associated_with => :person

  def to_s
    "IM Account"
  end

end

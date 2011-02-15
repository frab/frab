class ImAccount < ActiveRecord::Base

  TYPES = %w(aim icq jabber msn yahoo)

  belongs_to :person

end

class PhoneNumber < ActiveRecord::Base

  TYPES = %w(fax mobile phone private secretary skype work)

  belongs_to :person

end

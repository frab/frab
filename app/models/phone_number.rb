class PhoneNumber < ActiveRecord::Base

  TYPES = %w(fax mobile phone private secretary skype work)

  belongs_to :person

  acts_as_audited :associated_with => :person

end

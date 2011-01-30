class Person < ActiveRecord::Base

  has_many :event_people
  has_many :phone_numbers
  has_many :im_accounts
  has_many :events, :through => :event_people

  belongs_to :user

end

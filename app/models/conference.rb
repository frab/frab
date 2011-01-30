class Conference < ActiveRecord::Base

  has_many :events
  has_many :rooms
  has_many :tracks

end

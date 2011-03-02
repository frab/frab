class Conference < ActiveRecord::Base

  has_many :events
  has_many :rooms
  has_many :tracks

  accepts_nested_attributes_for :rooms, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :tracks, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title, :acronym
  validates_uniqueness_of :acronym

end

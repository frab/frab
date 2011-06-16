class Room < ActiveRecord::Base

  belongs_to :conference
  has_many :events

  acts_as_audited :associated_with => :conference

  default_scope order(:rank)

  scope :public, where(:public => true)

  def to_s
    "Room: #{self.name}"
  end

end

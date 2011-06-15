class Room < ActiveRecord::Base

  belongs_to :conference

  acts_as_audited :associated_with => :conference

  default_scope order(:rank)

  def to_s
    "Room: #{self.name}"
  end

end

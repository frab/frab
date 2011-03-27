class Track < ActiveRecord::Base

  belongs_to :conference

  acts_as_audited :associated_with => :conference

  def to_s
    "Track: #{self.name}"
  end

end

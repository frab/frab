class CallForParticipation < ActiveRecord::Base

  belongs_to :conference
  has_one :notification

  validates_presence_of :start_date, :end_date

  has_paper_trail

  def to_s
    "Call for Participation: #{self.conference.title}"
  end

end

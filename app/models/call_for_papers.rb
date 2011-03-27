class CallForPapers < ActiveRecord::Base

  belongs_to :conference

  validates_presence_of :start_date, :end_date

  acts_as_audited

  def to_s
    "Call for Papers: #{self.conference.title}"
  end

end

class CallForParticipation < ActiveRecord::Base
  belongs_to :conference

  validates_presence_of :start_date, :end_date

  has_paper_trail
end

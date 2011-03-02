class CallForPapers < ActiveRecord::Base

  belongs_to :conference

  validates_presence_of :start_date, :end_date

end

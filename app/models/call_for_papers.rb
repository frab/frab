class CallForPapers < ActiveRecord::Base

  belongs_to :conference
  has_many :notifications, dependent: :destroy

  accepts_nested_attributes_for :notifications, allow_destroy: true

  validates_presence_of :start_date, :end_date

  has_paper_trail

  def to_s
    "Call for Papers: #{self.conference.title}"
  end

end
